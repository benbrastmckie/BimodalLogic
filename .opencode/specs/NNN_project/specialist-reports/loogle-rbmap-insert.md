# Loogle Search Results: RBMap.insert

**Type Pattern**: RBMap.insert
**Date**: Sun Dec 21 2025
**Matches Found**: 11

## Exact Matches

### 1. **Batteries.RBMap.insert**
- **Type Signature**: `{α : Type u} {β : Type v} {cmp : α → α → Ordering} (t : Batteries.RBMap α β cmp) (k : α) (v : β) : Batteries.RBMap α β cmp`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Basic
- **Description**: `O(log n)`. Insert key-value pair `(k, v)` into the tree.
- **Usage**: Primary insertion function for red-black maps in Batteries library. Takes a map, a key, and a value, and returns a new map with the key-value pair inserted.

### 2. **Lean.RBMap.insert**
- **Type Signature**: `{α : Type u} {β : Type v} {cmp : α → α → Ordering} : Lean.RBMap α β cmp → α → β → Lean.RBMap α β cmp`
- **Library**: Lean
- **Module**: Lean.Data.RBMap
- **Description**: No documentation available
- **Usage**: Core Lean library insertion function for red-black maps. Functionally equivalent to Batteries version but from Lean's standard library.

## Supporting Lemmas

### 3. **Batteries.RBMap.find?_insert**
- **Type Signature**: `{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} [Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) (k : α) (v : β) (k' : α) : (t.insert k v).find? k' = if cmp k' k = Ordering.eq then some v else t.find? k'`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Specifies the behavior of `find?` after insertion - returns the inserted value if keys match, otherwise returns the original lookup result.

### 4. **Batteries.RBMap.find?_insert_of_eq**
- **Type Signature**: `{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k' k : α} {v : β} [Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) (h : cmp k' k = Ordering.eq) : (t.insert k v).find? k' = some v`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Proves that finding a key equal to the inserted key returns the inserted value.

### 5. **Batteries.RBMap.find?_insert_of_ne**
- **Type Signature**: `{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k' k : α} {v : β} [Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) (h : cmp k' k ≠ Ordering.eq) : (t.insert k v).find? k' = t.find? k'`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Proves that finding a key different from the inserted key returns the same result as before insertion.

### 6. **Batteries.RBMap.findEntry?_insert**
- **Type Signature**: `{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} [Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) (k : α) (v : β) (k' : α) : (t.insert k v).findEntry? k' = if cmp k' k = Ordering.eq then some (k, v) else t.findEntry? k'`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Similar to `find?_insert` but returns the full entry (key-value pair) instead of just the value.

### 7. **Batteries.RBMap.findEntry?_insert_of_eq**
- **Type Signature**: `{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k' k : α} {v : β} [Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) (h : cmp k' k = Ordering.eq) : (t.insert k v).findEntry? k' = some (k, v)`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Proves that finding an entry with a key equal to the inserted key returns the full inserted entry.

### 8. **Batteries.RBMap.findEntry?_insert_of_ne**
- **Type Signature**: `{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k' k : α} {v : β} [Std.TransCmp cmp] (t : Batteries.RBMap α β cmp) (h : cmp k' k ≠ Ordering.eq) : (t.insert k v).findEntry? k' = t.findEntry? k'`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Proves that finding an entry with a key different from the inserted key returns the same result as before insertion.

### 9. **Batteries.RBMap.mem_toList_insert_self**
- **Type Signature**: `{α : Type u_1} {β : Type u_2} {cmp : α → α → Ordering} {k : α} (v : β) (t : Batteries.RBMap α β cmp) : (k, v) ∈ (t.insert k v).toList`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Proves that the inserted key-value pair is a member of the list representation of the map after insertion.

### 10. **Batteries.RBMap.mem_toList_insert**
- **Type Signature**: `{α : Type u_1} {cmp : α → α → Ordering} {β : Type u_2} {k : α} {v : β} {y : α × β} [Std.TransCmp cmp] {t : Batteries.RBMap α β cmp} : y ∈ (t.insert k v).toList ↔ y ∈ t.toList ∧ t.findEntry? k ≠ some y ∨ y = (k, v)`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Characterizes membership in the list representation after insertion - an entry is in the result if it was in the original list and wasn't replaced, or if it's the newly inserted entry.

### 11. **Batteries.RBMap.mem_toList_insert_of_mem**
- **Type Signature**: `{α : Type u_1} {β : Type u_2} {cmp : α → α → Ordering} {y : α × β} {k : α} (v : β) {t : Batteries.RBMap α β cmp} (h : y ∈ t.toList) : y ∈ (t.insert k v).toList ∨ cmp k y.1 = Ordering.eq`
- **Library**: Batteries
- **Module**: Batteries.Data.RBMap.Lemmas
- **Relation**: Proves that if an entry was in the original list, it's either still in the list after insertion or its key equals the inserted key (meaning it was replaced).

## Recommendations

### For Basic Usage
Use **Batteries.RBMap.insert** for inserting key-value pairs into red-black maps. This is the primary, well-documented function with O(log n) complexity.

```lean
let map : RBMap String Nat compare := RBMap.empty
let map' := map.insert "key" 42
```

### For Reasoning About Insertions
The Batteries library provides comprehensive lemmas for reasoning about insertions:

1. **Lookup after insertion**: Use `find?_insert`, `find?_insert_of_eq`, or `find?_insert_of_ne` to reason about finding values after insertion.

2. **Entry lookup**: Use `findEntry?_insert` variants when you need to reason about full key-value pairs.

3. **Membership properties**: Use `mem_toList_insert` variants when reasoning about the list representation of the map.

### Library Choice
- **Batteries.RBMap**: Recommended for new code. Has extensive lemmas and documentation.
- **Lean.RBMap**: Core library version. Use if you need to avoid Batteries dependency, but note the lack of supporting lemmas.

### Type Class Requirements
Most lemmas require `[Std.TransCmp cmp]` instance, which ensures the comparison function is transitive. Make sure this instance is available when using these lemmas.

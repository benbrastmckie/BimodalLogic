# Loogle API Search Report: Ordering Comparison Functions

## Search Metadata

- **Search Pattern**: `_ -> _ -> Ordering` (matches `α → α → Ordering`)
- **Query Date**: 2025-12-21
- **API Endpoint**: https://loogle.lean-lang.org/json
- **Total Declarations Found**: 10,870 declarations mentioning `Ordering`
- **Pattern Matches**: 9,840 declarations match the type pattern
- **Results Returned**: 200 (first 200 matches shown by API)

## Search Summary

The Loogle API search successfully identified comparison functions in Lean that match the type pattern `α → α → Ordering`. These are functions that take two values of the same type and return an `Ordering` result (`.lt`, `.eq`, or `.gt`).

The search found:
- **Core comparison functions** from `Init.Data.Ord.Basic` and `Init.Data.Ord.Array`
- **Typeclass definitions** for lawful comparison (`LawfulEqCmp`, `OrientedCmp`, `TransCmp`, etc.)
- **Utility functions** for constructing comparisons from other relations
- **Theorems and lemmas** about comparison behavior

## Exact Matches: Core Comparison Functions

### 1. `Ord.compare`

**Type**: `{α : Type u} [self : Ord α] : α → α → Ordering`

**Module**: `Init.Data.Ord.Basic`

**Library**: Lean Core (Init)

**Documentation**:
> Compare two elements in `α` using the comparator contained in an `[Ord α]` instance.

**Usage**: This is the primary comparison function in Lean. It requires an `Ord α` instance and provides the canonical way to compare two values of type `α`.

**Example**:
```lean
#eval compare 5 3  -- Ordering.gt
#eval compare "apple" "banana"  -- Ordering.lt
```

---

### 2. `compareOfLessAndEq`

**Type**: `{α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [DecidableEq α] : Ordering`

**Module**: `Init.Data.Ord.Basic`

**Library**: Lean Core (Init)

**Documentation**:
> Uses decidable less-than and equality relations to find an `Ordering`.
>
> In particular, if `x < y` then the result is `Ordering.lt`. If `x = y` then the result is `Ordering.eq`. Otherwise, it is `Ordering.gt`.
>
> `compareOfLessAndBEq` uses `BEq` instead of `DecidableEq`.

**Usage**: Constructs a comparison function from a type's less-than relation and decidable equality. This is useful for building `Ord` instances from existing order relations.

---

### 3. `compareOfLessAndBEq`

**Type**: `{α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering`

**Module**: `Init.Data.Ord.Basic`

**Library**: Lean Core (Init)

**Documentation**:
> Uses a decidable less-than relation and Boolean equality to find an `Ordering`.
>
> In particular, if `x < y` then the result is `Ordering.lt`. If `x == y` then the result is `Ordering.eq`. Otherwise, it is `Ordering.gt`.
>
> `compareOfLessAndEq` uses `DecidableEq` instead of `BEq`.

**Usage**: Similar to `compareOfLessAndEq` but uses Boolean equality (`BEq`) instead of decidable equality. Useful when working with types that have custom equality implementations.

---

### 4. `compareOn`

**Type**: `{β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : Ordering`

**Module**: `Init.Data.Ord.Basic`

**Library**: Lean Core (Init)

**Documentation**:
> Compares two values by comparing the results of applying a function.
>
> In particular, `x` is compared to `y` by comparing `f x` and `f y`.
>
> Examples:
> * `compareOn (·.length) "apple" "banana" = .lt`
> * `compareOn (· % 3) 5 6 = .gt`
> * `compareOn (·.foldl max 0) [1, 2, 3] [3, 2, 1] = .eq`

**Usage**: Enables comparison based on a projection or transformation function. This is essential for sorting by computed values or struct fields.

---

### 5. `compareLex`

**Type**: `{α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : Ordering`

**Module**: `Init.Data.Ord.Basic`

**Library**: Lean Core (Init)

**Documentation**:
> Compares `a` and `b` lexicographically by `cmp₁` and `cmp₂`.
>
> `a` and `b` are first compared by `cmp₁`. If this returns `Ordering.eq`, `a` and `b` are compared by `cmp₂` to break the tie.
>
> To lexicographically combine two `Ordering`s, use `Ordering.then`.

**Usage**: Combines two comparison functions lexicographically. The second comparison is only used if the first returns `.eq`. This is crucial for multi-field comparisons.

---

### 6. `List.compareLex`

**Type**: `{α : Type u_1} (cmp : α → α → Ordering) : List α → List α → Ordering`

**Module**: `Init.Data.Ord.Basic`

**Library**: Lean Core (Init)

**Documentation**: (none provided)

**Usage**: Lexicographic comparison for lists using a given element comparison function. Compares lists element-by-element until a difference is found.

**Related Theorems**:
- `List.compareLex_nil_nil`: `List.compareLex cmp [] [] = Ordering.eq`
- `List.compareLex_cons_cons`: Shows how comparison works on non-empty lists
- `List.compare_eq_compareLex`: The default `compare` for lists uses `compareLex`

---

### 7. `Array.compareLex`

**Type**: `{α : Type u_1} (cmp : α → α → Ordering) (a₁ a₂ : Array α) : Ordering`

**Module**: `Init.Data.Ord.Array`

**Library**: Lean Core (Init)

**Documentation**: (none provided)

**Usage**: Lexicographic comparison for arrays, similar to `List.compareLex`. Implemented by converting to lists.

**Related Theorems**:
- `Array.compareLex_eq_compareLex_toList`: Shows equivalence with list comparison
- `Array.compare_eq_compareLex`: The default `compare` for arrays uses `compareLex`

---

### 8. `Ord.mk`

**Type**: `{α : Type u} (compare : α → α → Ordering) : Ord α`

**Module**: `Init.Data.Ord.Basic`

**Library**: Lean Core (Init)

**Documentation**: (none provided)

**Usage**: Constructor for the `Ord` typeclass. Takes a comparison function `α → α → Ordering` and creates an `Ord α` instance.

---

## Typeclass Definitions

These typeclass definitions specify properties that comparison functions should satisfy:

### 1. `Std.LawfulEqCmp`

**Type**: `{α : Type u} (cmp : α → α → Ordering) : Prop`

**Module**: `Init.Data.Order.Ord`

**Documentation**:
> A typeclass for comparison functions satisfying `cmp a b = .eq` if and only if the logical equality `a = b` holds.
>
> This typeclass distinguishes itself from `LawfulBEqCmp` by using logical equality (`=`) instead of boolean equality (`==`).

**Key Property**: `cmp a b = .eq ↔ a = b`

---

### 2. `Std.OrientedCmp`

**Type**: `{α : Type u} (cmp : α → α → Ordering) : Prop`

**Module**: `Init.Data.Order.Ord`

**Documentation**:
> A typeclass for functions `α → α → Ordering` which are oriented: flipping the arguments amounts to applying `Ordering.swap` to the return value.

**Key Property**: `cmp a b = (cmp b a).swap`

---

### 3. `Std.ReflCmp`

**Type**: `{α : Type u} (cmp : α → α → Ordering) : Prop`

**Module**: `Init.Data.Order.Ord`

**Documentation**:
> A typeclass for comparison functions `cmp` for which `cmp a a = .eq` for all `a`.

**Key Property**: `cmp a a = .eq`

---

### 4. `Std.TransCmp`

**Type**: `{α : Type u} (cmp : α → α → Ordering) : Prop`

**Module**: `Init.Data.Order.Ord`

**Documentation**:
> A typeclass for functions `α → α → Ordering` which are transitive.

**Key Property**: Transitivity of comparison results

---

### 5. `Std.LawfulBEqCmp`

**Type**: `{α : Type u} [BEq α] (cmp : α → α → Ordering) : Prop`

**Module**: `Init.Data.Order.Ord`

**Documentation**:
> A typeclass for comparison functions satisfying `cmp a b = .eq` if and only if the boolean equality `a == b` holds.
>
> This typeclass distinguishes itself from `LawfulEqCmp` by using boolean equality (`==`) instead of logical equality (`=`).

**Key Property**: `cmp a b = .eq ↔ (a == b) = true`

---

## Usage Recommendations

### For ProofChecker Project

1. **Custom Comparison for Modal Formulas**:
   - Use `Ord.mk` to define custom `Ord` instances for `Formula`
   - Consider using `compareOn` for comparing formulas by their structure
   - Use `compareLex` to build multi-criteria comparisons

2. **Proof Search Ordering**:
   - Implement comparison functions for prioritizing proof strategies
   - Use `compareOfLessAndEq` if you have a natural ordering on proof priorities
   - Consider `List.compareLex` for comparing proof sequences

3. **Tactic Development**:
   - When implementing sorting or ordering in tactics, use `Ord.compare`
   - For custom orderings, ensure they satisfy `Std.TransCmp` and `Std.OrientedCmp`
   - Use `Std.LawfulEqCmp` to ensure comparison respects equality

4. **Performance Considerations**:
   - `compareOfLessAndBEq` is more efficient than `compareOfLessAndEq` for types with fast boolean equality
   - `Array.compareLex` converts to lists internally, so consider direct list operations if already working with lists

### Best Practices

1. **Always implement lawful comparisons**:
   - Ensure your comparison functions satisfy the appropriate typeclasses
   - Use `Std.LawfulEqCmp` for correctness guarantees

2. **Compose comparisons lexicographically**:
   - Use `compareLex` or `Ordering.then` to combine multiple criteria
   - Example: Sort by priority first, then by formula complexity

3. **Test comparison functions**:
   - Verify reflexivity: `cmp a a = .eq`
   - Verify antisymmetry: `cmp a b = .lt → cmp b a = .gt`
   - Verify transitivity: appropriate transitivity laws hold

---

## Related Patterns to Explore

1. **`_ -> _ -> Bool`**: Boolean comparison predicates (`<`, `<=`, `>`, `>=`)
2. **`_ -> _ -> Prop`**: Propositional orderings and relations
3. **`Ord _`**: Complete `Ord` instances for various types
4. **`compare _ _`**: Specific comparison instances
5. **`_ -> Ordering`**: Unary functions returning `Ordering` (less common)

---

## API Query Details

### Loogle Query Syntax Used
```
_ -> _ -> Ordering
```

This pattern uses `_` as a wildcard that matches any type. It finds all functions that:
- Take two arguments of the same type
- Return an `Ordering` value

### Alternative Query Patterns

1. **Exact type variable**: `α → α → Ordering`
   - Note: May not work as expected due to identifier scoping

2. **With constraints**: Not directly supported in Loogle type search

3. **By name**: `compare` or `compareLex` (searches function names)

4. **Documentation search**: `"lexicographic comparison"` (searches doc strings)

---

## Appendix: Key Theorems and Lemmas

### Reflexivity
- `Std.ReflCmp.compare_self`: `{cmp : α → α → Ordering} [ReflCmp cmp] {a : α} : cmp a a = Ordering.eq`

### Symmetry
- `Std.OrientedCmp.eq_swap`: `{cmp : α → α → Ordering} [OrientedCmp cmp] {a b : α} : cmp a b = (cmp b a).swap`

### Transitivity
- `Std.TransCmp.lt_trans`: `{cmp : α → α → Ordering} [TransCmp cmp] : cmp a b = .lt → cmp b c = .lt → cmp a c = .lt`
- `Std.TransCmp.gt_trans`: Similar for `.gt`
- `Std.TransCmp.eq_trans`: Similar for `.eq`

### Lawfulness
- `Std.LawfulEqCmp.compare_eq_iff_eq`: `cmp a b = .eq ↔ a = b`
- `Std.LawfulBEqCmp.compare_eq_iff_beq`: `cmp a b = .eq ↔ (a == b) = true`

### List Comparison
- `List.compareLex_cons_cons`: Shows how `compareLex` decomposes on cons
- `List.compareLex_nil_nil`: Empty lists compare equal
- `List.compare_eq_compareLex`: Default list comparison uses `compareLex`

### Array Comparison
- `Array.compareLex_eq_compareLex_toList`: Relates array comparison to list comparison
- `Array.compare_eq_compareLex`: Default array comparison uses `compareLex`

---

## Implementation Examples

### Example 1: Custom Ord Instance

```lean
structure TaskPriority where
  urgency : Nat
  importance : Nat

instance : Ord TaskPriority where
  compare a b :=
    (compare a.urgency b.urgency).then (compare a.importance b.importance)
```

### Example 2: Comparison by Projection

```lean
-- Sort persons by age
def comparePersonsByAge (p1 p2 : Person) : Ordering :=
  compareOn (·.age) p1 p2
```

### Example 3: Using compareOfLessAndEq

```lean
-- For a type with LT and DecidableEq
def myCompare (x y : MyType) : Ordering :=
  compareOfLessAndEq x y
```

---

## Conclusion

The Loogle API search successfully identified 9,840 declarations matching the pattern `α → α → Ordering`, with the first 200 results providing comprehensive coverage of:

- **Core comparison functions** (`Ord.compare`, `compareOn`, `compareLex`)
- **Comparison constructors** (`compareOfLessAndEq`, `compareOfLessAndBEq`)
- **Specialized comparisons** (`List.compareLex`, `Array.compareLex`)
- **Lawfulness typeclasses** (`LawfulEqCmp`, `OrientedCmp`, `TransCmp`, `ReflCmp`)
- **Extensive theorem library** about comparison properties

These functions form the foundation for all ordering and comparison operations in Lean, and understanding them is essential for implementing custom orderings, sorting algorithms, and priority-based proof search strategies.

---

**Report Generated**: 2025-12-21  
**Tool**: Loogle API (https://loogle.lean-lang.org/)  
**Search Pattern**: `_ -> _ -> Ordering`  
**Total Matches**: 9,840 / 10,870 declarations

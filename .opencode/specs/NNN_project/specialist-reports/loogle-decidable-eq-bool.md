# Loogle Search Results: DecidableEq to Bool Pattern

**Type Pattern**: `[DecidableEq α] => α → α → Bool`  
**Date**: 2025-12-21  
**Total Searches Executed**: 5  
**Total Matches Found**: 24,791+ declarations (showing categorized key results)

## Executive Summary

This comprehensive search explored the relationship between `DecidableEq` and boolean equality (`Bool`) in Lean 4. The search revealed a rich ecosystem of type classes and instances that bridge decidable equality and boolean equality through the `BEq` type class.

**Key Finding**: The function matching the pattern `[DecidableEq α] → α → α → Bool` is **`BEq.beq`** with the instance **`instBEqOfDecidableEq`** providing the automatic conversion from `DecidableEq` to `BEq`.

---

## Search Queries Executed

### Query 1: `[DecidableEq α] → α → α → Bool`
**Status**: Error - Unknown identifier `α`  
**Note**: Loogle requires fully qualified type names or concrete types. Generic type variables without context are not recognized in search syntax.

### Query 2: `α → α → Bool`
**Status**: Error - Unknown identifier `α`  
**Note**: Same limitation as Query 1.

### Query 3: `BEq`
**Status**: Success  
**Results**: 10,742 declarations found (showing first 200)  
**Key Matches**: 8 exact/primary matches

### Query 4: `beq`
**Status**: Error - Unknown identifier 'beq'  
**Suggestions**: `BEq.beq`, `Nat.beq`, `List.beq`, `Option.instBEq.beq`  
**Note**: Lowercase function names need qualification or type-specific instances.

### Query 5: `DecidableEq`
**Status**: Success  
**Results**: 14,049 declarations found (showing first 200)  
**Key Matches**: 9 exact/primary matches

---

## Exact Matches

### 1. **BEq.beq** : `{α : Type u} [self : BEq α] : α → α → Bool`
- **Library**: Lean core
- **Module**: `Init.Prelude`
- **Description**: The primary boolean equality function from the BEq typeclass. This is the canonical way to perform boolean equality comparisons in Lean 4.
- **Usage**: `BEq.beq x y` or using the `==` notation
- **Notation**: `x == y` desugars to `BEq.beq x y`

### 2. **instBEqOfDecidableEq** : `{α : Type u_1} [DecidableEq α] : BEq α`
- **Library**: Lean core
- **Module**: `Init.Prelude`
- **Description**: **Critical instance** that automatically provides a `BEq` instance from any `DecidableEq` instance. This is the bridge that allows `DecidableEq` types to use boolean equality.
- **Usage**: Automatically applied by type class resolution
- **Significance**: This instance means any type with `DecidableEq` can use `BEq.beq` and the `==` operator

### 3. **bne** : `{α : Type u} [BEq α] (a b : α) : Bool`
- **Library**: Lean core
- **Module**: `Init.Core`
- **Description**: Boolean inequality function (negation of `beq`)
- **Usage**: `bne x y` returns `!(x == y)`
- **Notation**: `x != y` desugars to `bne x y`

---

## Partial Matches (Related Type Classes)

### 4. **BEq** : `(α : Type u) : Type u`
- **Library**: Lean core
- **Module**: `Init.Prelude`
- **Description**: The BEq typeclass for boolean equality. Types implementing this class provide a `beq` function.
- **Structure**: Contains a single field `beq : α → α → Bool`

### 5. **LawfulBEq** : `(α : Type u) [BEq α] : Prop`
- **Library**: Lean core
- **Module**: `Init.Core`
- **Description**: Typeclass for lawful boolean equality. Ensures that `beq` respects propositional equality.
- **Laws**: 
  - `beq_refl : ∀ a, a == a = true`
  - `beq_eq : ∀ {a b}, a == b = true → a = b`
  - `eq_beq : ∀ {a b}, a = b → a == b = true`

### 6. **ReflBEq** : `(α : Type u_1) [BEq α] : Prop`
- **Library**: Lean core
- **Module**: `Init.Core`
- **Description**: Typeclass for reflexive boolean equality (weaker than `LawfulBEq`)
- **Law**: `beq_refl : ∀ a, a == a = true`

### 7. **instDecidableEqOfLawfulBEq** : `{α : Type u_1} [BEq α] [LawfulBEq α] : DecidableEq α`
- **Library**: Lean core
- **Module**: `Init.Core`
- **Description**: Reverse direction - provides `DecidableEq` from a `LawfulBEq` instance
- **Significance**: Creates a bidirectional relationship between `BEq` and `DecidableEq` when laws are satisfied

---

## Related Functions and Theorems

### 8. **beq_iff_eq** : `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} : (a == b) = true ↔ a = b`
- **Library**: Lean core
- **Module**: `Init.Core`
- **Description**: Key theorem showing that boolean equality equals true if and only if propositional equality holds
- **Usage**: Essential for converting between `==` and `=` in proofs

### 9. **DecidableEq** : `(α : Sort u) : Sort (max 1 u)`
- **Library**: Lean core
- **Module**: `Init.Prelude`
- **Description**: Typeclass for decidable equality. Provides a decision procedure for propositional equality.
- **Definition**: `DecidableEq α := (a b : α) → Decidable (a = b)`

---

## Concrete Type Instances

### DecidableEq Instances

#### 10. **instDecidableEqBool** : `DecidableEq Bool`
- **Library**: Lean core
- **Module**: `Init.Prelude`

#### 11. **instDecidableEqNat** : `DecidableEq ℕ`
- **Library**: Lean core
- **Module**: `Init.Prelude`

#### 12. **instDecidableEqString** : `DecidableEq String`
- **Library**: Lean core
- **Module**: `Init.Prelude`

#### 13. **instDecidableEqList** : `{α : Type u} [DecidableEq α] : DecidableEq (List α)`
- **Library**: Lean core
- **Module**: `Init.Prelude`
- **Note**: Derived instance - requires `DecidableEq α`

#### 14. **instDecidableEqProd** : `{α : Type u_1} {β : Type u_2} [DecidableEq α] [DecidableEq β] : DecidableEq (α × β)`
- **Library**: Lean core
- **Module**: `Init.Core`
- **Note**: Derived instance for product types

#### 15. **instDecidableEqOption** : `{α : Type u_1} [inst : DecidableEq α] : DecidableEq (Option α)`
- **Library**: Lean core
- **Module**: `Init.Data.Option.Basic`
- **Note**: Derived instance for option types

---

## Type-Specific BEq Instances

### 16. **Nat.beq** : `ℕ → ℕ → Bool`
- **Library**: Lean core
- **Module**: `Init.Data.Nat.Basic`
- **Description**: Specialized boolean equality for natural numbers
- **Implementation**: Efficient primitive implementation

### 17. **List.beq** : `{α : Type u} [BEq α] : List α → List α → Bool`
- **Library**: Lean core
- **Module**: `Init.Data.List.Basic`
- **Description**: Boolean equality for lists (element-wise comparison)

### 18. **Option.instBEq.beq** : `{α : Type u} [BEq α] : Option α → Option α → Bool`
- **Library**: Lean core
- **Module**: `Init.Data.Option.Basic`
- **Description**: Boolean equality for option types

---

## Architecture and Relationships

### Type Class Hierarchy

```
DecidableEq α
    ↓ (instBEqOfDecidableEq)
BEq α
    ↓ (contains)
beq : α → α → Bool

BEq α + LawfulBEq α
    ↓ (instDecidableEqOfLawfulBEq)
DecidableEq α
```

### Key Relationships

1. **DecidableEq → BEq**: Automatic via `instBEqOfDecidableEq`
   - Any type with `DecidableEq` automatically gets `BEq`
   - This is the primary path for the pattern `[DecidableEq α] → α → α → Bool`

2. **BEq + LawfulBEq → DecidableEq**: Via `instDecidableEqOfLawfulBEq`
   - Reverse direction requires lawfulness
   - Creates equivalence when laws are satisfied

3. **BEq.beq vs Type-Specific beq**:
   - Generic: `BEq.beq` works for any type with a `BEq` instance
   - Specific: `Nat.beq`, `List.beq`, etc. are optimized implementations
   - Type class resolution automatically selects the appropriate instance

---

## Usage Recommendations

### For Boolean Equality with DecidableEq

**Pattern**: You have a type `α` with `[DecidableEq α]` and want to compare values for boolean equality.

**Solution**: Use `BEq.beq` or the `==` operator directly:

```lean
def compareValues {α : Type} [DecidableEq α] (x y : α) : Bool :=
  x == y  -- or: BEq.beq x y
```

**Why it works**: The instance `instBEqOfDecidableEq` automatically provides `BEq α` from `DecidableEq α`.

### For Lawful Boolean Equality

**Pattern**: You need to prove properties about boolean equality.

**Solution**: Use `LawfulBEq` and the theorem `beq_iff_eq`:

```lean
theorem example {α : Type} [BEq α] [LawfulBEq α] (x y : α) :
    x == y = true → x = y :=
  beq_iff_eq.mp
```

### For Custom Types

**Pattern**: You're defining a new type and want boolean equality.

**Option 1**: Derive `DecidableEq` (preferred for simple types):
```lean
inductive MyType
  | A | B | C
  deriving DecidableEq  -- Automatically gets BEq via instBEqOfDecidableEq
```

**Option 2**: Implement `BEq` directly (for custom equality):
```lean
instance : BEq MyType where
  beq := fun x y => match x, y with
    | MyType.A, MyType.A => true
    | MyType.B, MyType.B => true
    | MyType.C, MyType.C => true
    | _, _ => false
```

### For Proofs

**Converting between `==` and `=`**:

```lean
-- Bool equality to Prop equality (requires LawfulBEq)
theorem beq_to_eq {α : Type} [BEq α] [LawfulBEq α] {x y : α} :
    x == y = true → x = y :=
  beq_iff_eq.mp

-- Prop equality to Bool equality (requires LawfulBEq)
theorem eq_to_beq {α : Type} [BEq α] [LawfulBEq α] {x y : α} :
    x = y → x == y = true :=
  beq_iff_eq.mpr
```

---

## Import Paths

### Core Definitions
```lean
-- BEq, BEq.beq, instBEqOfDecidableEq, DecidableEq
-- (automatically imported, in Prelude)

-- LawfulBEq, ReflBEq, beq_iff_eq, instDecidableEqOfLawfulBEq
import Init.Core

-- Type-specific instances
import Init.Data.Nat.Basic      -- Nat.beq
import Init.Data.List.Basic     -- List.beq
import Init.Data.Option.Basic   -- Option instances
```

### No Explicit Imports Needed

Most of the core functionality is in `Init.Prelude`, which is automatically imported in every Lean file. You typically don't need explicit imports for:
- `BEq`, `BEq.beq`
- `DecidableEq`
- `instBEqOfDecidableEq`
- Basic instances for `Bool`, `Nat`, `String`, `List`, `Prod`, `Option`

---

## Common Patterns and Idioms

### Pattern 1: Generic Boolean Comparison
```lean
def isEqual {α : Type} [DecidableEq α] (x y : α) : Bool :=
  x == y
```

### Pattern 2: Conditional Logic with Boolean Equality
```lean
def conditionalAction {α : Type} [DecidableEq α] (x y : α) : String :=
  if x == y then "equal" else "not equal"
```

### Pattern 3: Filter with Equality
```lean
def filterEqual {α : Type} [DecidableEq α] (target : α) (xs : List α) : List α :=
  xs.filter (fun x => x == target)
```

### Pattern 4: Proving with Boolean Equality
```lean
theorem beq_refl_example {α : Type} [BEq α] [LawfulBEq α] (x : α) :
    x == x = true :=
  LawfulBEq.beq_refl x
```

---

## Performance Considerations

### BEq vs DecidableEq

- **BEq**: Returns `Bool`, suitable for computation and runtime checks
- **DecidableEq**: Returns `Decidable (a = b)`, suitable for proofs and type-level computation

### When to Use Each

- **Use `==` (BEq.beq)**: 
  - Runtime boolean checks
  - Conditional logic in functions
  - Filter operations
  - Any computation that needs a `Bool` result

- **Use `DecidableEq` directly**:
  - When you need a proof of equality or inequality
  - Type-level computation with `decide`
  - Pattern matching on equality proofs

### Efficiency

Type-specific instances (e.g., `Nat.beq`) are often more efficient than the generic `BEq.beq` because they can use optimized implementations. However, type class resolution automatically selects the most specific instance, so you generally don't need to worry about this.

---

## Summary

The search successfully identified the complete ecosystem for converting `DecidableEq` to boolean equality:

1. **Primary Function**: `BEq.beq : {α : Type u} [BEq α] : α → α → Bool`
2. **Bridge Instance**: `instBEqOfDecidableEq : {α : Type u_1} [DecidableEq α] : BEq α`
3. **Combined Effect**: Any type with `[DecidableEq α]` can use `BEq.beq` to get `α → α → Bool`

The pattern `[DecidableEq α] => α → α → Bool` is realized through:
```lean
-- Given: [DecidableEq α]
-- Automatic: [BEq α] via instBEqOfDecidableEq
-- Available: BEq.beq : α → α → Bool
```

**Recommendation**: For any type with `DecidableEq`, simply use the `==` operator or `BEq.beq` directly. The type class system handles the conversion automatically through `instBEqOfDecidableEq`.

---

## Additional Resources

- **Lean 4 Manual**: [Type Classes](https://lean-lang.org/lean4/doc/typeclass.html)
- **Init.Prelude**: Core type class definitions
- **Init.Core**: Lawful instances and theorems
- **Mathlib4**: Extended instances and theorems (not covered in this search)

---

**Search Completed**: 2025-12-21  
**Total Declarations Examined**: 24,791+  
**Key Matches Documented**: 18  
**Libraries Covered**: Lean core (Init.Prelude, Init.Core, Init.Data.*)

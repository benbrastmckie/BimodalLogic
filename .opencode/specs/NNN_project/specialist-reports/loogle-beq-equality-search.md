# Loogle Search Results: BEq Equality Functions

**Search Date**: Sun Dec 21 2025
**Type Pattern**: [BEq α] => α → α → Bool
**Total Matches Found**: 2 exact matches + 200+ related functions

## Search Queries Executed

1. `[BEq α] => α → α → Bool` - **Syntax Error** (Loogle uses different syntax)
2. `{α : Type} → [BEq α] → α → α → Bool` - **2 exact matches**
3. `[BEq _] => _ → _ → Bool` - **Syntax Error** (Loogle uses different syntax)
4. `"beq"` - **1302+ name matches** (showing first 200)
5. `BEq` - **10742+ constant mentions** (showing first 200)

## Exact Matches

### BEq.beq

**Function**: `BEq.beq`
**Type**: `{α : Type u} [self : BEq α] : α → α → Bool`
**Module**: `Init.Prelude`
**Library**: Lean core
**Documentation**: The primary polymorphic Boolean equality function provided by the BEq typeclass. This is the function that gets invoked when using the `==` operator notation in Lean.

**Usage Notes**:
- This is the canonical BEq equality function
- Accessed via the `==` operator notation
- Requires a BEq instance for type α
- Returns Bool (not Prop)

---

### bne

**Function**: `bne`
**Type**: `{α : Type u} [BEq α] (a b : α) : Bool`
**Module**: `Init.Core`
**Library**: Lean core
**Documentation**: Boolean not-equal function, the negation of BEq.beq. Accessed via the `!=` operator notation.

**Definition**: `bne a b := !(a == b)`

**Usage Notes**:
- Defined in terms of BEq.beq
- Accessed via the `!=` operator notation
- Equivalent to `!a == b`

---

## Close Matches

### Nat.beq

**Function**: `Nat.beq`
**Type**: `ℕ → ℕ → Bool`
**Module**: `Init.Prelude`
**Library**: Lean core
**Similarity**: Specific instance for natural numbers; no explicit BEq constraint in signature but provides the beq implementation for Nat's BEq instance
**Documentation**: Natural number equality comparison

**Related Theorems**:
- `Nat.beq_eq`: `{x y : ℕ} : (x.beq y = true) = (x = y)`
- `Nat.beq_refl`: `(a : ℕ) : a.beq a = true`
- `Nat.eq_of_beq_eq_true`: `{n m : ℕ} : n.beq m = true → n = m`
- `Nat.ne_of_beq_eq_false`: `{n m : ℕ} : n.beq m = false → ¬n = m`

---

### Lean.Name.beq

**Function**: `Lean.Name.beq`
**Type**: `Lean.Name → Lean.Name → Bool`
**Module**: `Init.Prelude`
**Library**: Lean core
**Similarity**: Specific instance for Lean.Name type
**Documentation**: Name equality comparison for Lean identifiers

**Related Theorems**:
- `Lean.Name.beq_iff_eq`: `{m n : Lean.Name} : (m == n) = true ↔ m = n`

---

### List.beq

**Function**: `List.beq`
**Type**: `{α : Type u} [BEq α] : List α → List α → Bool`
**Module**: `Init.Data.List.Basic`
**Library**: Lean core
**Similarity**: Takes lists of BEq types and compares them elementwise
**Documentation**: List equality based on elementwise BEq comparison

**Recursive Definition**:
```lean
[].beq [] = true
(a :: as).beq (b :: bs) = (a == b && as.beq bs)
_ = false  -- different structure
```

**Related Theorems**:
- `List.beq_nil_nil`: `[].beq [] = true`
- `List.beq_cons₂`: `(a :: as).beq (b :: bs) = (a == b && as.beq bs)`

---

### Option.instBEq.beq

**Function**: `Option.instBEq.beq`
**Type**: `{α✝ : Type u_1} [BEq α✝] : Option α✝ → Option α✝ → Bool`
**Module**: `Init.Data.Option.Basic`
**Library**: Lean core
**Similarity**: BEq instance implementation for Option type
**Documentation**: Option equality based on inner BEq comparison

**Related Theorems**:
- `Option.none_beq_none`: `(none == none) = true`
- `Option.none_beq_some`: `(none == some a) = false`
- `Option.some_beq_some`: `(some a == some b) = (a == b)`

---

### Array.instBEq

**Function**: `Array.instBEq`
**Type**: `{α : Type u} [BEq α] : BEq (Array α)`
**Module**: `Init.Data.Array.Basic`
**Library**: Lean core
**Similarity**: BEq instance for Array type (provides beq for arrays)
**Documentation**: Array equality based on elementwise comparison

---

### Int.beq'

**Function**: `Int.beq'`
**Type**: `(a b : ℤ) : Bool`
**Module**: `Init.Data.Int.Basic`
**Library**: Lean core
**Similarity**: Alternative integer equality implementation
**Documentation**: Alternative beq implementation for integers

**Related Theorems**:
- `Int.beq'_eq`: `(a b : ℤ) : (a.beq' b = true) = (a = b)`
- `Int.beq'_eq_beq`: `(a b : ℤ) : a.beq' b = (a == b)`

---

## Related Functions

### BEq (typeclass)

**Function**: `BEq`
**Type**: `(α : Type u) : Type u`
**Module**: `Init.Prelude`
**Library**: Lean core
**Relation**: The fundamental typeclass that provides Boolean equality
**Documentation**: Typeclass for types that support Boolean equality comparison

**Constructor**: `BEq.mk {α : Type u} (beq : α → α → Bool) : BEq α`

---

### LawfulBEq (typeclass)

**Function**: `LawfulBEq`
**Type**: `(α : Type u) [BEq α] : Prop`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Typeclass asserting that BEq.beq agrees with propositional equality
**Documentation**: Asserts that `(a == b) = true ↔ a = b`

**Key Property**: `LawfulBEq.eq_of_beq : {a b : α} : (a == b) = true → a = b`

**Instances**:
- `instLawfulBEqBool`
- `instLawfulBEqChar`
- `instLawfulBEqString`
- `Nat.instLawfulBEq`
- `Int.instLawfulBEq`
- `List.instLawfulBEq {α} [BEq α] [LawfulBEq α]`
- `Option.instLawfulBEq (α) [BEq α] [LawfulBEq α]`
- `Prod.instLawfulBEq {α β} [BEq α] [BEq β] [LawfulBEq α] [LawfulBEq β]`
- `Subtype.instLawfulBEq {α} {p} [BEq α] [LawfulBEq α]`

---

### ReflBEq (typeclass)

**Function**: `ReflBEq`
**Type**: `(α : Type u_1) [BEq α] : Prop`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Weaker version of LawfulBEq asserting only reflexivity
**Documentation**: Asserts that `(a == a) = true` for all a

**Key Property**: `ReflBEq.rfl : {a : α} : (a == a) = true`

**Note**: `LawfulBEq α` implies `ReflBEq α`

---

### EquivBEq (typeclass)

**Function**: `EquivBEq`
**Type**: `(α : Type u_1) [BEq α] : Prop`
**Module**: `Init.Data.BEq`
**Library**: Lean core
**Relation**: Asserts BEq.beq is an equivalence relation
**Documentation**: Combines PartialEquivBEq and ReflBEq

**Properties**: Reflexive, symmetric, and transitive

---

### PartialEquivBEq (typeclass)

**Function**: `PartialEquivBEq`
**Type**: `(α : Type u_1) [BEq α] : Prop`
**Module**: `Init.Data.BEq`
**Library**: Lean core
**Relation**: Asserts BEq.beq is symmetric and transitive
**Documentation**: Partial equivalence (lacks only reflexivity)

**Key Properties**:
- `PartialEquivBEq.symm : {a b : α} : (a == b) = true → (b == a) = true`
- `PartialEquivBEq.trans : {a b c : α} : (a == b) = true → (b == c) = true → (a == c) = true`

---

### beq_iff_eq

**Function**: `beq_iff_eq`
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} : (a == b) = true ↔ a = b`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Key theorem connecting Boolean and propositional equality
**Documentation**: The fundamental soundness and completeness property for LawfulBEq

---

### beq_of_eq

**Function**: `beq_of_eq`
**Type**: `{α : Type u_1} [BEq α] [ReflBEq α] {a b : α} : a = b → (a == b) = true`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Soundness: propositional equality implies Boolean equality
**Documentation**: If types are propositionally equal, they are BEq equal (requires only ReflBEq)

---

### beq_false_of_ne

**Function**: `beq_false_of_ne`
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} (h : a ≠ b) : (a == b) = false`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Inequality implies beq returns false
**Documentation**: Contrapositive of the "true implies equal" direction

---

### ne_of_beq_false

**Function**: `ne_of_beq_false`
**Type**: `{α : Type u_1} [BEq α] [ReflBEq α] {a b : α} (h : (a == b) = false) : a ≠ b`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: beq false implies inequality (requires only ReflBEq)
**Documentation**: Contrapositive of beq_of_eq

---

### BEq.refl / BEq.rfl

**Function**: `BEq.refl` / `BEq.rfl`
**Type**: `{α : Type u_1} [BEq α] [ReflBEq α] (a : α) : (a == a) = true`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Reflexivity property
**Documentation**: Every element is BEq-equal to itself

---

### BEq.comm

**Function**: `BEq.comm`
**Type**: `{α : Type u_1} [BEq α] [PartialEquivBEq α] {a b : α} : (a == b) = (b == a)`
**Module**: `Init.Data.BEq`
**Library**: Lean core
**Relation**: Symmetry property
**Documentation**: BEq is commutative (requires PartialEquivBEq)

---

### BEq.trans

**Function**: `BEq.trans`
**Type**: `{α : Type u_1} [BEq α] [PartialEquivBEq α] {a b c : α} : (a == b) = true → (b == c) = true → (a == c) = true`
**Module**: `Init.Data.BEq`
**Library**: Lean core
**Relation**: Transitivity property
**Documentation**: BEq is transitive (requires PartialEquivBEq)

---

### instBEqOfDecidableEq

**Function**: `instBEqOfDecidableEq`
**Type**: `{α : Type u_1} [DecidableEq α] : BEq α`
**Module**: `Init.Prelude`
**Library**: Lean core
**Relation**: Automatic BEq instance from DecidableEq
**Documentation**: Every type with decidable equality automatically gets a BEq instance

**Note**: This instance is automatically LawfulBEq

---

### instDecidableEqOfLawfulBEq

**Function**: `instDecidableEqOfLawfulBEq`
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] : DecidableEq α`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Automatic DecidableEq from LawfulBEq
**Documentation**: LawfulBEq provides decidable propositional equality

---

### instBEqProd

**Function**: `instBEqProd`
**Type**: `{α : Type u_1} {β : Type u_2} [BEq α] [BEq β] : BEq (α × β)`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Product type BEq instance
**Documentation**: Pairs are equal iff both components are BEq-equal

---

### Subtype.instBEq

**Function**: `Subtype.instBEq`
**Type**: `{α : Type u} {p : α → Prop} [BEq α] : BEq { x // p x }`
**Module**: `Init.Core`
**Library**: Lean core
**Relation**: Subtype BEq instance
**Documentation**: Subtype equality based on underlying type equality

**Related**: `Subtype.beq_iff : (x == y) = (↑x == ↑y)`

---

### Std.LawfulOrderBEq

**Function**: `Std.LawfulOrderBEq`
**Type**: `(α : Type u) [BEq α] [LE α] : Prop`
**Module**: `Init.Data.Order.Classes`
**Library**: Lean Std
**Relation**: BEq compatible with partial order
**Documentation**: Asserts `(a == b) = true ↔ a ≤ b ∧ b ≤ a`

**Key Property**: Connects BEq with order-theoretic equality

---

### beq_self_eq_true

**Function**: `beq_self_eq_true`
**Type**: `{α : Type u_1} [BEq α] [ReflBEq α] (a : α) : (a == a) = true`
**Module**: `Init.SimpLemmas`
**Library**: Lean core
**Relation**: Simplification lemma for reflexivity
**Documentation**: Registered as simp lemma for automatic simplification

---

### beq_eq_false_iff_ne

**Function**: `beq_eq_false_iff_ne`
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} : (a == b) = false ↔ a ≠ b`
**Module**: `Init.SimpLemmas`
**Library**: Lean core
**Relation**: Biconditional for beq false
**Documentation**: Useful for case analysis on beq results

---

### bne_iff_ne

**Function**: `bne_iff_ne`
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} : (a != b) = true ↔ a ≠ b`
**Module**: `Init.SimpLemmas`
**Library**: Lean core
**Relation**: bne agrees with propositional inequality
**Documentation**: The iff version for bne

---

### bne_eq_false_iff_eq

**Function**: `bne_eq_false_iff_eq`
**Type**: `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} : (a != b) = false ↔ a = b`
**Module**: `Init.SimpLemmas`
**Library**: Lean core
**Relation**: bne false means equality
**Documentation**: Contrapositive form

---

## Summary

- **Exact matches**: 2 (`BEq.beq`, `bne`)
- **Close matches (type-specific beq)**: 6+ (`Nat.beq`, `Lean.Name.beq`, `List.beq`, `Option.instBEq.beq`, `Array.instBEq`, `Int.beq'`)
- **Related typeclasses**: 5 (`BEq`, `LawfulBEq`, `ReflBEq`, `EquivBEq`, `PartialEquivBEq`)
- **Related theorems**: 20+ key theorems and lemmas
- **Total functions found**: 1302+ with "beq" in name, 10742+ mentioning BEq

## Recommendations

### Most Commonly Used BEq Equality Functions

1. **`BEq.beq` / `==` operator** - The universal choice
   - Use for any type with a BEq instance
   - Most general and idiomatic
   - Import: automatically available (Init.Prelude)

2. **`Nat.beq`** - For natural numbers
   - Specific to Nat
   - Slightly more efficient than generic BEq.beq for Nat
   - Import: automatically available (Init.Prelude)

3. **`List.beq`** - For lists
   - Elementwise comparison
   - Requires BEq instance for element type
   - Import: automatically available (Init.Data.List.Basic)

4. **`bne` / `!=` operator** - Boolean inequality
   - Negation of BEq.beq
   - Import: Init.Core

### When to Use Each Variant

**Use `BEq.beq` / `==` when:**
- You need Boolean equality in computational contexts
- You're working with decidable types
- You need fast equality checking
- You're in a context where Prop would be too heavy

**Use propositional equality (`=`) when:**
- You're proving theorems
- You need to rewrite/substitute
- You're working in Type/Prop contexts
- You need more powerful reasoning

**Use `LawfulBEq` when:**
- You need to connect Boolean and propositional equality
- You're proving that `==` and `=` agree
- You need `beq_iff_eq` theorem

**Use `ReflBEq` when:**
- You only need reflexivity (weaker than LawfulBEq)
- You're working with equivalence relations that aren't equality
- You need `beq_of_eq` but not the converse

### Import Paths Needed

Most BEq functions are in the Lean core prelude and automatically available:

- `BEq.beq`, `bne`: Automatically available (Init.Prelude, Init.Core)
- `LawfulBEq`, `ReflBEq`: Automatically available (Init.Core)
- `Nat.beq`: Automatically available (Init.Prelude)
- `List.beq`: Automatically available (Init.Data.List.Basic)
- `Option.instBEq`: Automatically available (Init.Data.Option.Basic)
- `Array.instBEq`: Automatically available (Init.Data.Array.Basic)
- `EquivBEq`, `PartialEquivBEq`: Init.Data.BEq

**No explicit imports needed for basic usage!**

### Common Patterns and Usage Examples

#### Pattern 1: Using BEq in Definitions

```lean
def contains [BEq α] (xs : List α) (x : α) : Bool :=
  xs.any (· == x)
```

#### Pattern 2: Proving BEq Properties

```lean
theorem beq_of_eq_example {α : Type} [BEq α] [ReflBEq α] 
    (a b : α) (h : a = b) : (a == b) = true :=
  beq_of_eq h
```

#### Pattern 3: Using LawfulBEq to Connect == and =

```lean
theorem example {α : Type} [BEq α] [LawfulBEq α] 
    (a b : α) : (a == b) = true → a = b :=
  LawfulBEq.eq_of_beq

-- Or use the iff version
theorem example' {α : Type} [BEq α] [LawfulBEq α] 
    (a b : α) : (a == b) = true ↔ a = b :=
  beq_iff_eq
```

#### Pattern 4: Case Analysis on BEq Results

```lean
def partition [BEq α] (xs : List α) (pivot : α) : List α × List α :=
  match h : (x == pivot) with
  | true => ... -- use LawfulBEq.eq_of_beq h : x = pivot
  | false => ... -- use ne_of_beq_false h : x ≠ pivot
```

#### Pattern 5: Implementing Custom BEq Instances

```lean
structure Point where
  x : Nat
  y : Nat

instance : BEq Point where
  beq p1 p2 := p1.x == p2.x && p1.y == p2.y

-- Prove it's lawful
instance : LawfulBEq Point where
  eq_of_beq {p1 p2} h := by
    -- proof that beq true implies equality
    ...
  rfl {p} := by
    -- proof of reflexivity
    simp [BEq.beq]
```

#### Pattern 6: Using Decidable Equality via BEq

```lean
def deduplicate [BEq α] [LawfulBEq α] (xs : List α) : List α :=
  xs.eraseDups

-- LawfulBEq provides DecidableEq, enabling decidable membership
def isMember [BEq α] [LawfulBEq α] (x : α) (xs : List α) : Bool :=
  if x ∈ xs then true else false
```

### Key Insights

1. **`BEq.beq` is THE canonical function** - signature `{α : Type u} [BEq α] : α → α → Bool`

2. **Type-specific variants** (like `Nat.beq`, `List.beq`) are implementation details of the typeclass instances

3. **LawfulBEq is crucial** for connecting Boolean (`==`) and propositional (`=`) equality

4. **The hierarchy**: `LawfulBEq → ReflBEq` and `LawfulBEq → EquivBEq → PartialEquivBEq + ReflBEq`

5. **Automatic instances**: Any `DecidableEq` type gets `BEq` and `LawfulBEq` for free

6. **Common simp lemmas**: `beq_self_eq_true`, `beq_iff_eq`, `beq_eq_false_iff_ne` are registered for automation

---

## Additional Notes

### Performance Considerations

- `BEq.beq` is generally faster than decidable equality proofs
- Type-specific implementations (e.g., `Nat.beq`) may be optimized
- Use BEq for runtime equality checks, use `=` for proofs

### Relationship to Decidable Equality

```lean
DecidableEq α  ⟷  BEq α + LawfulBEq α
```

These are interderivable:
- `instBEqOfDecidableEq`: DecidableEq → BEq
- `instDecidableEqOfLawfulBEq`: BEq + LawfulBEq → DecidableEq

### Common Pitfalls

1. **Forgetting LawfulBEq**: You need `[LawfulBEq α]` to use `beq_iff_eq`
2. **Confusing `==` with `=`**: `==` is Bool, `=` is Prop
3. **Missing instances**: Not all types have BEq instances by default
4. **Custom instances**: When implementing BEq, also implement LawfulBEq if possible

### Future Research Directions

1. Investigate BEq instances in Mathlib (not covered in this search)
2. Explore specialized BEq implementations for custom types
3. Study BEq-based algorithms and data structures
4. Examine the performance characteristics of different BEq implementations

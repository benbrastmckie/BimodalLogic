# Loogle Search Results: beq

**Search Pattern**: "beq" (name-based search)  
**Date**: Sun Dec 21 2025  
**Matches Found**: 1302 (showing first 200)  
**Search URL**: https://loogle.lean-lang.org/?q="beq"

## Executive Summary

The Loogle search for "beq" (boolean equality) revealed 1302 declarations across Lean 4's standard library, Mathlib, and related libraries. This comprehensive search identifies all boolean equality-related functions, instances, and theorems available in the Lean ecosystem.

### Key Findings

1. **Core BEq Typeclass**: The fundamental `BEq` typeclass and its method `BEq.beq` form the foundation of boolean equality in Lean 4
2. **Lawful Instances**: Multiple "lawful" variants (`LawfulBEq`, `ReflBEq`, `PartialEquivBEq`, `EquivBEq`) ensure type-safe equality
3. **Broad Coverage**: BEq instances exist for primitive types, collections, meta-programming types, and domain-specific structures
4. **Integration with Decidability**: Close integration with `DecidableEq` for proof-level equality

## Core BEq Typeclass and Methods

### Primary Typeclass

1. **BEq** : `(α : Type u) : Type u`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: Core typeclass for boolean equality

2. **BEq.beq** : `{α : Type u} [self : BEq α] : α → α → Bool`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: The method that performs boolean equality checking

3. **BEq.mk** : `{α : Type u} (beq : α → α → Bool) : BEq α`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: Constructor for BEq instances

### Lawful Variants

1. **LawfulBEq** : `(α : Type u) [BEq α] : Prop`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Ensures beq is logically equivalent to equality

2. **ReflBEq** : `(α : Type u_1) [BEq α] : Prop`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Ensures reflexivity: `a == a = true`

3. **EquivBEq** : `(α : Type u_1) [BEq α] : Prop`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Ensures beq is an equivalence relation

4. **PartialEquivBEq** : `(α : Type u_1) [BEq α] : Prop`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Ensures symmetry and transitivity

### Order-Based Variants

1. **Std.LawfulOrderBEq** : `(α : Type u) [BEq α] [LE α] : Prop`
   - Library: Init.Data.Order.Classes
   - Module: Init.Data.Order.Classes
   - Documentation: BEq defined via partial order (`a == b ↔ a ≤ b ∧ b ≤ a`)

## BEq Instances for Primitive Types

### Numeric Types

1. **Nat.beq** : `ℕ → ℕ → Bool`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: Boolean equality for natural numbers

2. **Int.beq'** : `(a b : ℤ) : Bool`
   - Library: Init.Data.Int.Basic
   - Module: Init.Data.Int.Basic
   - Documentation: Boolean equality for integers

3. **Float.beq** : Listed in suggestions
   - Library: Various
   - Module: Various
   - Documentation: Boolean equality for floating-point numbers

4. **Float32.beq** : Listed in suggestions
   - Library: Various
   - Module: Various
   - Documentation: Boolean equality for 32-bit floats

### Character and String Types

1. **instLawfulBEqChar** : `LawfulBEq Char`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Lawful BEq instance for characters

2. **instLawfulBEqString** : `LawfulBEq String`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Lawful BEq instance for strings

3. **String.Slice.beq** : Listed in suggestions
   - Library: Various
   - Module: Various
   - Documentation: Boolean equality for string slices

4. **Substring.beq** : Listed in suggestions
   - Library: Various
   - Module: Various
   - Documentation: Boolean equality for substrings

### Boolean Type

1. **instLawfulBEqBool** : `LawfulBEq Bool`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Lawful BEq instance for booleans

## BEq Instances for Collections

### Lists

1. **List.instBEq** : `{α : Type u} [BEq α] : BEq (List α)`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: BEq instance for lists

2. **List.beq** : `{α : Type u} [BEq α] : List α → List α → Bool`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: Boolean equality function for lists

3. **List.instLawfulBEq** : `{α : Type u} [BEq α] [LawfulBEq α] : LawfulBEq (List α)`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: Lawful BEq instance for lists (requires element type to be lawful)

4. **List.instReflBEq** : `{α : Type u} [BEq α] [ReflBEq α] : ReflBEq (List α)`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: Reflexive BEq instance for lists

### Arrays and Byte Collections

1. **Array.instBEq** : `{α : Type u} [BEq α] : BEq (Array α)`
   - Library: Init.Data.Array.Basic
   - Module: Init.Data.Array.Basic
   - Documentation: BEq instance for arrays

2. **ByteArray.instBEq.beq** : Listed in suggestions
   - Library: Various
   - Module: Various
   - Documentation: Boolean equality for byte arrays

3. **ByteSlice.beq** : Listed in suggestions
   - Library: Various
   - Module: Various
   - Documentation: Boolean equality for byte slices

4. **FloatArray.instBEq.beq** : Listed in suggestions
   - Library: Various
   - Module: Various
   - Documentation: Boolean equality for float arrays

### Options and Products

1. **Option.instBEq** : `{α✝ : Type u_1} [BEq α✝] : BEq (Option α✝)`
   - Library: Init.Data.Option.Basic
   - Module: Init.Data.Option.Basic
   - Documentation: BEq instance for options

2. **Option.instBEq.beq** : `{α✝ : Type u_1} [BEq α✝] : Option α✝ → Option α✝ → Bool`
   - Library: Init.Data.Option.Basic
   - Module: Init.Data.Option.Basic
   - Documentation: Boolean equality function for options

3. **Option.instLawfulBEq** : `(α : Type u_1) [BEq α] [LawfulBEq α] : LawfulBEq (Option α)`
   - Library: Init.Data.Option.Basic
   - Module: Init.Data.Option.Basic
   - Documentation: Lawful BEq instance for options

4. **instBEqProd** : `{α : Type u_1} {β : Type u_2} [BEq α] [BEq β] : BEq (α × β)`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: BEq instance for product types

### Hash-Based Collections

1. **Std.HashMap.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.DHashMap
   - Documentation: Boolean equality for hash maps

2. **Std.HashSet.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.DHashMap
   - Documentation: Boolean equality for hash sets

3. **Std.DHashMap.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.DHashMap.Internal
   - Documentation: Boolean equality for dependent hash maps

4. **Std.DHashSet.Raw.beq** : Listed in suggestions (implied)
   - Library: Std
   - Module: Std.DHashMap
   - Documentation: Boolean equality for raw hash sets

### Tree-Based Collections

1. **Std.TreeMap.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.DTreeMap
   - Documentation: Boolean equality for tree maps

2. **Std.TreeSet.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.DTreeMap
   - Documentation: Boolean equality for tree sets

3. **Std.DTreeMap.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.DTreeMap.Internal
   - Documentation: Boolean equality for dependent tree maps

## BEq Instances for Lean Meta Types

### Names and Syntax

1. **Lean.Name.instBEq** : `BEq Lean.Name`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: BEq instance for Lean names

2. **Lean.Name.beq** : `Lean.Name → Lean.Name → Bool`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: Boolean equality for Lean names

3. **Lean.Name.instLawfulBEq** : `LawfulBEq Lean.Name`
   - Library: Init.Meta.Defs
   - Module: Init.Meta.Defs
   - Documentation: Lawful BEq instance for Lean names

4. **Lean.Syntax.instBEq** : `BEq Lean.Syntax`
   - Library: Init.Meta.Defs
   - Module: Init.Meta.Defs
   - Documentation: BEq instance for Lean syntax trees

5. **Lean.Syntax.instBEqTSyntax** : `{k : Lean.SyntaxNodeKinds} : BEq (Lean.TSyntax k)`
   - Library: Init.Meta.Defs
   - Module: Init.Meta.Defs
   - Documentation: BEq instance for typed syntax

### Levels and Expressions

1. **Lean.Level.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Expr
   - Documentation: Boolean equality for universe levels

2. **Lean.ExprStructEq.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Expr
   - Documentation: Structural equality for expressions

3. **Lean.instBEqLiteral.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Expr
   - Documentation: Boolean equality for literals

### Meta Configuration Types

1. **Lean.Meta.instBEqTransparencyMode** : `BEq Lean.Meta.TransparencyMode`
   - Library: Init.MetaTypes
   - Module: Init.MetaTypes
   - Documentation: BEq for transparency modes

2. **Lean.Meta.instBEqOccurrences** : `BEq Lean.Meta.Occurrences`
   - Library: Init.MetaTypes
   - Module: Init.MetaTypes
   - Documentation: BEq for occurrence specifications

3. **Lean.Meta.Simp.instBEqConfig** : `BEq Lean.Meta.Simp.Config`
   - Library: Init.MetaTypes
   - Module: Init.MetaTypes
   - Documentation: BEq for simplifier configuration

4. **Lean.Meta.DSimp.instBEqConfig** : `BEq Lean.Meta.DSimp.Config`
   - Library: Init.MetaTypes
   - Module: Init.MetaTypes
   - Documentation: BEq for definitional simplifier configuration

5. **Lean.Grind.instBEqConfig** : `BEq Lean.Grind.Config`
   - Library: Init.Grind.Config
   - Module: Init.Grind.Config
   - Documentation: BEq for grind tactic configuration

### Declaration Types

1. **Lean.instBEqDeclaration.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Declaration
   - Documentation: Boolean equality for declarations

2. **Lean.instBEqConstantVal.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Declaration
   - Documentation: Boolean equality for constant values

3. **Lean.instBEqDefinitionVal.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Declaration
   - Documentation: Boolean equality for definition values

4. **Lean.instBEqTheoremVal.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Declaration
   - Documentation: Boolean equality for theorem values

### IR Types

1. **Lean.IR.Arg.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.IR
   - Documentation: Boolean equality for IR arguments

2. **Lean.IR.FnBody.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.IR
   - Documentation: Boolean equality for IR function bodies

3. **Lean.IR.instBEqIRType.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.IR
   - Documentation: Boolean equality for IR types

### LCNF Compiler Types

1. **Lean.Compiler.LCNF.Code.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Compiler.LCNF
   - Documentation: Boolean equality for LCNF code

2. **Lean.Compiler.LCNF.instBEqArg.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Compiler.LCNF
   - Documentation: Boolean equality for LCNF arguments

3. **Lean.Compiler.LCNF.instBEqLetValue.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Compiler.LCNF
   - Documentation: Boolean equality for LCNF let values

## BEq Theorems and Lemmas

### Core Properties

1. **beq_iff_eq** : `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} : (a == b) = true ↔ a = b`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Equivalence between boolean and propositional equality for lawful instances

2. **beq_of_eq** : `{α : Type u_1} [BEq α] [ReflBEq α] {a b : α} : a = b → (a == b) = true`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Propositional equality implies boolean equality

3. **ne_of_beq_false** : `{α : Type u_1} [BEq α] [ReflBEq α] {a b : α} (h : (a == b) = false) : a ≠ b`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: False boolean equality implies propositional inequality

4. **beq_false_of_ne** : `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} (h : a ≠ b) : (a == b) = false`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Propositional inequality implies false boolean equality

### Reflexivity

1. **BEq.refl** : `{α : Type u_1} [BEq α] [ReflBEq α] (a : α) : (a == a) = true`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Reflexivity of boolean equality

2. **BEq.rfl** : `{α : Type u_1} [BEq α] [ReflBEq α] {a : α} : (a == a) = true`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Reflexivity (implicit version)

3. **beq_self_eq_true** : `{α : Type u_1} [BEq α] [ReflBEq α] (a : α) : (a == a) = true`
   - Library: Init.SimpLemmas
   - Module: Init.SimpLemmas
   - Documentation: Simp lemma for self-equality

4. **beq_self_eq_true'** : `{α : Type u_1} [DecidableEq α] (a : α) : (a == a) = true`
   - Library: Init.SimpLemmas
   - Module: Init.SimpLemmas
   - Documentation: Simp lemma for self-equality (DecidableEq version)

### Symmetry and Transitivity

1. **BEq.comm** : `{α : Type u_1} [BEq α] [PartialEquivBEq α] {a b : α} : (a == b) = (b == a)`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Commutativity of boolean equality

2. **BEq.symm** : `{α : Type u_1} [BEq α] [Std.Symm fun x1 x2 => (x1 == x2) = true] {a b : α} : (a == b) = true → (b == a) = true`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Symmetry of boolean equality

3. **BEq.trans** : `{α : Type u_1} [BEq α] [PartialEquivBEq α] {a b c : α} : (a == b) = true → (b == c) = true → (a == c) = true`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Transitivity of boolean equality

4. **PartialEquivBEq.trans** : `{α : Type u_1} {inst✝ : BEq α} [self : PartialEquivBEq α] {a b c : α} : (a == b) = true → (b == c) = true → (a == c) = true`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Transitivity for partial equivalence relations

### Congruence

1. **BEq.congr_left** : `{α : Type u_1} [BEq α] [PartialEquivBEq α] {a b c : α} (h : (a == b) = true) : (a == c) = (b == c)`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Left congruence for boolean equality

2. **BEq.congr_right** : `{α : Type u_1} [BEq α] [PartialEquivBEq α] {a b c : α} (h : (b == c) = true) : (a == b) = (a == c)`
   - Library: Init.Data.BEq
   - Module: Init.Data.BEq
   - Documentation: Right congruence for boolean equality

### Boolean-Specific Lemmas

1. **beq_true** : `(b : Bool) : (b == true) = b`
   - Library: Init.SimpLemmas
   - Module: Init.SimpLemmas
   - Documentation: Comparing with true simplifies to the value

2. **beq_false** : `(b : Bool) : (b == false) = !b`
   - Library: Init.SimpLemmas
   - Module: Init.SimpLemmas
   - Documentation: Comparing with false simplifies to negation

3. **Bool.beq_to_eq** : `(a b : Bool) : ((a == b) = true) = (a = b)`
   - Library: Init.SimpLemmas
   - Module: Init.SimpLemmas
   - Documentation: Boolean equality equivalence

4. **Bool.true_beq** : `(b : Bool) : (true == b) = b`
   - Library: Init.Data.Bool
   - Module: Init.Data.Bool
   - Documentation: True compared with b equals b

5. **Bool.false_beq** : `(b : Bool) : (false == b) = !b`
   - Library: Init.Data.Bool
   - Module: Init.Data.Bool
   - Documentation: False compared with b equals negation

6. **Bool.beq_not_self** : `(x : Bool) : (x == !x) = false`
   - Library: Init.Data.Bool
   - Module: Init.Data.Bool
   - Documentation: Value never equals its negation

7. **Bool.beq_comm** : `{α : Type u_1} [BEq α] [LawfulBEq α] {a b : α} : (a == b) = (b == a)`
   - Library: Init.Data.Bool
   - Module: Init.Data.Bool
   - Documentation: General commutativity for lawful BEq

### Natural Number Lemmas

1. **Nat.beq_refl** : `(a : ℕ) : a.beq a = true`
   - Library: Init.Data.Nat.Basic
   - Module: Init.Data.Nat.Basic
   - Documentation: Reflexivity for Nat.beq

2. **Nat.beq_eq** : `{x y : ℕ} : (x.beq y = true) = (x = y)`
   - Library: Init.Data.Nat.Basic
   - Module: Init.Data.Nat.Basic
   - Documentation: Nat.beq equivalence with equality

3. **Nat.eq_of_beq_eq_true** : `{n m : ℕ} : n.beq m = true → n = m`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: Extract equality from beq

4. **Nat.ne_of_beq_eq_false** : `{n m : ℕ} : n.beq m = false → ¬n = m`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: Extract inequality from false beq

5. **Nat.instLawfulBEq** : `LawfulBEq ℕ`
   - Library: Init.Data.Nat.Basic
   - Module: Init.Data.Nat.Basic
   - Documentation: Nat has lawful boolean equality

### Integer Lemmas

1. **Int.beq'_eq** : `(a b : ℤ) : (a.beq' b = true) = (a = b)`
   - Library: Init.Data.Int.Lemmas
   - Module: Init.Data.Int.Lemmas
   - Documentation: Int.beq' equivalence with equality

2. **Int.beq'_eq_beq** : `(a b : ℤ) : a.beq' b = (a == b)`
   - Library: Init.Data.Int.Lemmas
   - Module: Init.Data.Int.Lemmas
   - Documentation: Equivalence of beq' with standard beq

3. **Int.beq'_ne** : `(a b : ℤ) : (a.beq' b = false) = (a ≠ b)`
   - Library: Init.Data.Int.Lemmas
   - Module: Init.Data.Int.Lemmas
   - Documentation: False beq' implies inequality

4. **Int.instLawfulBEq** : `LawfulBEq ℤ`
   - Library: Init.Data.Int.Basic
   - Module: Init.Data.Int.Basic
   - Documentation: Int has lawful boolean equality

### List Lemmas

1. **List.beq_nil_nil** : `{α : Type u} [BEq α] : [].beq [] = true`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: Empty lists are equal

2. **List.beq_cons_nil** : `{α : Type u} [BEq α] {a : α} {as : List α} : (a :: as).beq [] = false`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: Non-empty list not equal to empty list

3. **List.beq_nil_cons** : `{α : Type u} [BEq α] {a : α} {as : List α} : [].beq (a :: as) = false`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: Empty list not equal to non-empty list

4. **List.beq_cons₂** : `{α : Type u} [BEq α] {a b : α} {as bs : List α} : (a :: as).beq (b :: bs) = (a == b && as.beq bs)`
   - Library: Init.Data.List.Basic
   - Module: Init.Data.List.Basic
   - Documentation: Cons equality is head equality and tail equality

5. **List.cons_beq_cons** : `{α : Type u_1} [BEq α] {a b : α} {l₁ l₂ : List α} : (a :: l₁ == b :: l₂) = (a == b && l₁ == l₂)`
   - Library: Init.Data.List.Lemmas
   - Module: Init.Data.List.Lemmas
   - Documentation: Standard notation version of cons equality

6. **List.nil_beq_eq** : `{α : Type u_1} [BEq α] {l : List α} : ([] == l) = l.isEmpty`
   - Library: Init.Data.List.Lemmas
   - Module: Init.Data.List.Lemmas
   - Documentation: Empty list equals another iff that list is empty

7. **List.beq_nil_eq** : `{α : Type u_1} [BEq α] {l : List α} : (l == []) = l.isEmpty`
   - Library: Init.Data.List.Lemmas
   - Module: Init.Data.List.Lemmas
   - Documentation: List equals empty iff it's empty

8. **List.lawfulBEq_iff** : `{α : Type u_1} [BEq α] : LawfulBEq (List α) ↔ LawfulBEq α`
   - Library: Init.Data.List.Lemmas
   - Module: Init.Data.List.Lemmas
   - Documentation: List has lawful BEq iff element type does

9. **List.reflBEq_iff** : `{α : Type u_1} [BEq α] : ReflBEq (List α) ↔ ReflBEq α`
   - Library: Init.Data.List.Lemmas
   - Module: Init.Data.List.Lemmas
   - Documentation: List has reflexive BEq iff element type does

### Option Lemmas

1. **Option.none_beq_none** : `{α : Type u_1} [BEq α] : (none == none) = true`
   - Library: Init.Data.Option.Lemmas
   - Module: Init.Data.Option.Lemmas
   - Documentation: None equals none

2. **Option.none_beq_some** : `{α : Type u_1} [BEq α] (a : α) : (none == some a) = false`
   - Library: Init.Data.Option.Lemmas
   - Module: Init.Data.Option.Lemmas
   - Documentation: None doesn't equal some

3. **Option.some_beq_none** : `{α : Type u_1} [BEq α] (a : α) : (some a == none) = false`
   - Library: Init.Data.Option.Lemmas
   - Module: Init.Data.Option.Lemmas
   - Documentation: Some doesn't equal none

4. **Option.some_beq_some** : `{α : Type u_1} [BEq α] {a b : α} : (some a == some b) = (a == b)`
   - Library: Init.Data.Option.Lemmas
   - Module: Init.Data.Option.Lemmas
   - Documentation: Some values equal iff their contents equal

5. **Option.beq_none** : `{α : Type u_1} [BEq α] {o : Option α} : (o == none) = o.isNone`
   - Library: Init.Data.Option.Lemmas
   - Module: Init.Data.Option.Lemmas
   - Documentation: Equality with none is isNone

6. **Option.lawfulBEq_iff** : `{α : Type u_1} [BEq α] : LawfulBEq (Option α) ↔ LawfulBEq α`
   - Library: Init.Data.Option.Lemmas
   - Module: Init.Data.Option.Lemmas
   - Documentation: Option has lawful BEq iff element type does

7. **Option.reflBEq_iff** : `{α : Type u_1} [BEq α] : ReflBEq (Option α) ↔ ReflBEq α`
   - Library: Init.Data.Option.Lemmas
   - Module: Init.Data.Option.Lemmas
   - Documentation: Option has reflexive BEq iff element type does

### Subtype Lemmas

1. **Subtype.beq_iff** : `{α : Type u} [BEq α] {p : α → Prop} {x y : { a // p a }} : (x == y) = (↑x == ↑y)`
   - Library: Init.Data.Bool
   - Module: Init.Data.Bool
   - Documentation: Subtype equality is coercion equality

2. **Subtype.instBEq** : `{α : Type u} {p : α → Prop} [BEq α] : BEq { x // p x }`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: BEq instance for subtypes

3. **Subtype.instLawfulBEq** : `{α : Type u} {p : α → Prop} [BEq α] [LawfulBEq α] : LawfulBEq { x // p x }`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Lawful BEq for subtypes

### Order-Based Lemmas

1. **Std.beq_iff_le_and_ge** : `{α : Type u} [BEq α] [LE α] [Std.LawfulOrderBEq α] {a b : α} : (a == b) = true ↔ a ≤ b ∧ b ≤ a`
   - Library: Init.Data.Order.Lemmas
   - Module: Init.Data.Order.Lemmas
   - Documentation: Order-based equality characterization

2. **Std.LawfulOrderBEq.beq_iff_le_and_ge** : `{α : Type u} {inst✝ : BEq α} {inst✝¹ : LE α} [self : Std.LawfulOrderBEq α] (a b : α) : (a == b) = true ↔ a ≤ b ∧ b ≤ a`
   - Library: Init.Data.Order.Classes
   - Module: Init.Data.Order.Classes
   - Documentation: Typeclass method version

## Utility Functions Using BEq

### Construction Functions

1. **instBEqOfDecidableEq** : `{α : Type u_1} [DecidableEq α] : BEq α`
   - Library: Init.Prelude
   - Module: Init.Prelude
   - Documentation: Construct BEq from DecidableEq

2. **instDecidableEqOfLawfulBEq** : `{α : Type u_1} [BEq α] [LawfulBEq α] : DecidableEq α`
   - Library: Init.Core
   - Module: Init.Core
   - Documentation: Construct DecidableEq from LawfulBEq

3. **beqOfOrd** : `{α : Type u_1} [Ord α] : BEq α`
   - Library: Init.Data.Ord.Basic
   - Module: Init.Data.Ord.Basic
   - Documentation: Construct BEq from Ord

4. **Ord.toBEq** : `{α : Type u_1} (ord : Ord α) : BEq α`
   - Library: Init.Data.Ord.Basic
   - Module: Init.Data.Ord.Basic
   - Documentation: Convert Ord to BEq

5. **compareOfLessAndBEq** : `{α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering`
   - Library: Init.Data.Ord.Basic
   - Module: Init.Data.Ord.Basic
   - Documentation: Construct ordering from LT and BEq

### Deriving Helpers

1. **DerivingHelpers.deriving_lawful_beq_helper_nd** : Listed in full signature
   - Library: Init.LawfulBEqTactics
   - Module: Init.LawfulBEqTactics
   - Documentation: Helper for deriving lawful BEq (non-dependent)

2. **DerivingHelpers.deriving_lawful_beq_helper_dep** : Listed in full signature
   - Library: Init.LawfulBEqTactics
   - Module: Init.LawfulBEqTactics
   - Documentation: Helper for deriving lawful BEq (dependent)

## Domain-Specific BEq Instances

### Mathlib Data Structures

1. **Batteries.AssocList.beq** : Listed in suggestions
   - Library: Mathlib/Batteries
   - Module: Batteries.Data.AssocList
   - Documentation: Boolean equality for association lists

### Format and Pretty-Printing

1. **Std.Format.instBEqFlattenAllowability** : `BEq Std.Format.FlattenAllowability`
   - Library: Init.Data.Format.Basic
   - Module: Init.Data.Format.Basic
   - Documentation: BEq for format flattening allowability

2. **Std.Format.instBEqFlattenBehavior** : `BEq Std.Format.FlattenBehavior`
   - Library: Init.Data.Format.Basic
   - Module: Init.Data.Format.Basic
   - Documentation: BEq for format flattening behavior

### LSP and JSON-RPC

1. **Lean.Lsp.instBEqPosition.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Lsp
   - Documentation: Boolean equality for LSP positions

2. **Lean.Lsp.instBEqRange.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Lsp
   - Documentation: Boolean equality for LSP ranges

3. **Lean.JsonRpc.instBEqRequestID.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.JsonRpc
   - Documentation: Boolean equality for JSON-RPC request IDs

4. **Lean.JsonRpc.instBEqRequest.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.JsonRpc
   - Documentation: Boolean equality for JSON-RPC requests

### Tactic and Proof Search

1. **Aesop.instBEqOptions.beq** : Listed in suggestions
   - Library: Aesop
   - Module: Aesop
   - Documentation: Boolean equality for Aesop options

2. **Aesop.instBEqStrategy.beq** : Listed in suggestions
   - Library: Aesop
   - Module: Aesop
   - Documentation: Boolean equality for Aesop strategies

3. **Lean.Meta.instBEqDefEqCacheKey.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Meta
   - Documentation: Boolean equality for definitional equality cache keys

4. **Lean.Meta.DiscrTree.instBEqKey.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Meta.DiscrTree
   - Documentation: Boolean equality for discrimination tree keys

### Grind Tactic

1. **Lean.Grind.instBEqIntInterval.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Grind
   - Documentation: Boolean equality for integer intervals

2. **Lean.Meta.Grind.instBEqCnstrRHS.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Meta.Grind
   - Documentation: Boolean equality for constraint RHS

3. **Lean.Meta.Grind.instBEqEMatchTheoremKind.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Meta.Grind
   - Documentation: Boolean equality for E-matching theorem kinds

### Omega Tactic

1. **Lean.Omega.instBEqConstraint** : `BEq Lean.Omega.Constraint`
   - Library: Init.Omega.Constraint
   - Module: Init.Omega.Constraint
   - Documentation: BEq for Omega constraints

2. **Lean.Omega.instBEqConstraint.beq** : `Lean.Omega.Constraint → Lean.Omega.Constraint → Bool`
   - Library: Init.Omega.Constraint
   - Module: Init.Omega.Constraint
   - Documentation: Boolean equality function for Omega constraints

### Linear Arithmetic

1. **Nat.Linear.instBEqExpr** : `BEq Nat.Linear.Expr`
   - Library: Init.Data.Nat.Linear
   - Module: Init.Data.Nat.Linear
   - Documentation: BEq for natural number linear expressions

2. **Nat.Linear.instBEqPolyCnstr** : `BEq Nat.Linear.PolyCnstr`
   - Library: Init.Data.Nat.Linear
   - Module: Init.Data.Nat.Linear
   - Documentation: BEq for natural number polynomial constraints

3. **Int.Linear.instBEqExpr.beq** : Listed in suggestions
   - Library: Init
   - Module: Init.Data.Int.Linear
   - Documentation: Boolean equality for integer linear expressions

4. **Int.Linear.instBEqPoly.beq** : Listed in suggestions
   - Library: Init
   - Module: Init.Data.Int.Linear
   - Documentation: Boolean equality for integer polynomials

### BVDecide Tactic

1. **Std.Tactic.BVDecide.Gate.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.Tactic.BVDecide
   - Documentation: Boolean equality for bit-vector gates

2. **Std.Tactic.BVDecide.LRAT.instBEqAction.beq** : Listed in suggestions
   - Library: Std
   - Module: Std.Tactic.BVDecide.LRAT
   - Documentation: Boolean equality for LRAT actions

### Documentation System

1. **Lean.Doc.instBEqBlock.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Doc
   - Documentation: Boolean equality for documentation blocks

2. **Lean.Doc.instBEqInline.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Doc
   - Documentation: Boolean equality for inline documentation elements

### Widget System

1. **Lean.Widget.instBEqTaggedText.beq** : Listed in suggestions
   - Library: Lean
   - Module: Lean.Widget
   - Documentation: Boolean equality for tagged text (used in info view)

### IO and File System

1. **IO.FS.instBEqFileType.beq** : Listed in suggestions
   - Library: Init
   - Module: Init.System.IO
   - Documentation: Boolean equality for file types

2. **IO.FS.instBEqSystemTime.beq** : Listed in suggestions
   - Library: Init
   - Module: Init.System.IO
   - Documentation: Boolean equality for system times

## Related Comparison Functions

### Ordering-Related

1. **Ordering.isEq_eq_beq_eq** : `{o : Ordering} : o.isEq = (o == Ordering.eq)`
   - Library: Init.Data.Ord.Basic
   - Module: Init.Data.Ord.Basic
   - Documentation: isEq check via beq

2. **Ordering.isLT_eq_beq_lt** : `{o : Ordering} : o.isLT = (o == Ordering.lt)`
   - Library: Init.Data.Ord.Basic
   - Module: Init.Data.Ord.Basic
   - Documentation: isLT check via beq

3. **Ordering.isGT_eq_beq_gt** : `{o : Ordering} : o.isGT = (o == Ordering.gt)`
   - Library: Init.Data.Ord.Basic
   - Module: Init.Data.Ord.Basic
   - Documentation: isGT check via beq

4. **Ordering.eq_beq_lt** : `(Ordering.eq == Ordering.lt) = false`
   - Library: Init.Data.Ord.Basic
   - Module: Init.Data.Ord.Basic
   - Documentation: Ordering values are distinct

### Decision Procedures

1. **Bool.beq_eq_decide_eq** : `{α : Type u_1} [BEq α] [LawfulBEq α] [DecidableEq α] (a b : α) : (a == b) = decide (a = b)`
   - Library: Init.Data.Bool
   - Module: Init.Data.Bool
   - Documentation: BEq equals decide for lawful instances

2. **Bool.decide_beq_decide** : `(p q : Prop) [dpq : Decidable (p ↔ q)] [dp : Decidable p] [dq : Decidable q] : (decide p == decide q) = decide (p ↔ q)`
   - Library: Init.Data.Bool
   - Module: Init.Data.Bool
   - Documentation: Relating beq of decisions to decision of biconditional

### Simplification Lemmas

1. **Nat.Simproc.beqFalseOfEqFalse** : `{a b : ℕ} (p : (a = b) = False) : (a == b) = false`
   - Library: Init.Data.Nat.Simproc
   - Module: Init.Data.Nat.Simproc
   - Documentation: Simproc support for Nat beq

2. **Nat.Simproc.beqEqOfEqEq** : `{a b c d : ℕ} (p : (a = b) = (c = d)) : (a == b) = (c == d)`
   - Library: Init.Data.Nat.Simproc
   - Module: Init.Data.Nat.Simproc
   - Documentation: Simproc support for Nat beq equations

## Analysis and Patterns

### Type Hierarchies

The BEq typeclass has a clear hierarchy:
1. **BEq** - Basic boolean equality
2. **ReflBEq** - Adds reflexivity guarantee
3. **PartialEquivBEq** - Adds symmetry and transitivity
4. **EquivBEq** - Full equivalence relation (= PartialEquivBEq + ReflBEq)
5. **LawfulBEq** - Equivalence with propositional equality (= EquivBEq + correspondence to `=`)
6. **Std.LawfulOrderBEq** - Equality defined via partial order

### Instance Patterns

1. **Primitive Types**: Direct implementations (Nat, Int, Bool, Char, String, Float)
2. **Containers**: Structural recursion on elements (List, Array, Option, Product)
3. **Meta Types**: Custom implementations based on internal representation
4. **Derived Types**: Use underlying type's BEq (Subtype, TSyntax)

### Integration Points

1. **DecidableEq**: Bidirectional conversion with LawfulBEq
2. **Ord**: Can generate BEq from comparison
3. **LE**: Can define BEq via partial order
4. **Simplifier**: Extensive simp lemmas for automatic simplification
5. **Deriving**: Automatic generation via deriving handlers

### Performance Considerations

1. BEq is intended for efficient boolean comparison
2. Should be implemented as structural equality where possible
3. For complex types, consider caching or fast-path checks
4. LawfulBEq enables optimizations by compiler

### Common Use Cases

1. **Membership Testing**: Lists, Sets, Maps use BEq for containment checks
2. **Caching**: Cache keys often use BEq for lookup
3. **Pattern Matching**: Guard expressions with `==`
4. **Proof Automation**: Simp lemmas convert beq to propositional equality
5. **Meta-programming**: Comparing syntax trees, expressions, etc.

## Recommendations for ProofChecker Project

### For Modal Logic Formulas

Consider implementing BEq instances for:
1. **Formula** type - Structural equality over syntax
2. **Context** type - Comparison of hypothesis lists
3. **WorldHistory** type - Temporal sequence equality
4. **TaskFrame** type - Frame structure comparison

### Implementation Strategy

```lean
-- Example pattern for Formula
instance : BEq Formula where
  beq
    | .var n, .var m => n == m
    | .neg φ, .neg ψ => φ == ψ
    | .conj φ₁ φ₂, .conj ψ₁ ψ₂ => φ₁ == ψ₁ && φ₂ == ψ₂
    | .impl φ₁ φ₂, .impl ψ₁ ψ₂ => φ₁ == ψ₁ && φ₂ == ψ₂
    | .box φ, .box ψ => φ == ψ
    | .dia φ, .dia ψ => φ == ψ
    | _, _ => false

-- Prove LawfulBEq to enable optimizations and proof automation
instance : LawfulBEq Formula := ...
```

### Benefits for ProofChecker

1. **Efficient Caching**: Cache proof attempts by formula structure
2. **Pattern Matching**: Use in tactics with guard conditions
3. **Proof Search**: Quick equality checks during search
4. **Testing**: Compare expected vs actual results
5. **Normalization**: Detect when formulas are syntactically equal

## Summary

The "beq" search revealed a comprehensive boolean equality infrastructure in Lean 4:

- **1302 total matches** across all libraries
- **Core typeclass** with clear hierarchy (BEq → ReflBEq → PartialEquivBEq → EquivBEq → LawfulBEq)
- **Universal coverage** from primitives to complex meta-programming types
- **Strong guarantees** via lawful variants enabling proof automation
- **Extensive lemma library** for reasoning about boolean equality
- **Integration** with decidability, ordering, and simplification systems

The BEq typeclass is a fundamental component of Lean 4's type system, providing efficient runtime equality checks while maintaining soundness guarantees through its lawful variants. For the ProofChecker project, implementing BEq instances for modal logic types would enable efficient comparison operations and unlock powerful proof automation capabilities.

## Additional Resources

- Lean 4 Manual: https://lean-lang.org/lean4/doc/
- Mathlib Docs: https://leanprover-community.github.io/mathlib4_docs/
- Loogle: https://loogle.lean-lang.org/
- BEq in Std4: https://github.com/leanprover/std4/blob/main/Std/Classes/BEq.lean

## Appendix: Full Type Signatures (First 200 Results)

Due to space constraints, this report shows the first 200 of 1302 matches. For complete results including all Mathlib-specific instances, Aesop integration, tactic-specific types, and specialized data structures, visit the Loogle search URL directly.

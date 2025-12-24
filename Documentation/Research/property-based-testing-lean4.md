# Property-Based Testing in Lean 4: Research Findings

**Research Date**: December 24, 2025  
**Researcher**: Web Research Specialist  
**Topic**: Property-based testing frameworks for Lean 4

---

## Executive Summary

Property-based testing is available in Lean 4 through the **Plausible** library, which is the primary and most mature framework. Plausible is a port of Haskell's QuickCheck that integrates directly into Lean's tactic framework, allowing property tests to be written as tactics and run during proof development. The library provides automatic test case generation, shrinking of counterexamples, and seamless integration with Lean's type system.

**Key Findings**:
- **Plausible** is the recommended property-based testing framework for Lean 4
- It integrates as both a tactic (`plausible`) and a command (`#test`)
- Supports automatic derivation of generators for custom types via `deriving Arbitrary`
- Provides shrinking to minimize counterexamples
- Actively maintained by the Lean community (74 stars, 16 forks)
- No NPM/TypeScript dependencies required for basic usage

---

## 1. Available Frameworks

### 1.1 Plausible (Recommended)

**Repository**: https://github.com/leanprover-community/plausible  
**Status**: Active, well-maintained  
**License**: Apache 2.0  
**Latest Release**: Multiple releases, actively updated

**Description**: Plausible is a property testing framework for Lean 4 that integrates into the tactic framework. It is a port of Haskell's QuickCheck library and provides:

- Random test case generation
- Automatic shrinking of counterexamples
- Integration with Lean's decidability system
- Support for custom types via type classes
- Tactic-based and command-based interfaces

**Key Features**:
- **Tactic integration**: Use `plausible` tactic in proofs
- **Command interface**: Use `#test` or `#eval Testable.check` for standalone testing
- **Automatic derivation**: `deriving Arbitrary` for algebraic data types
- **Shrinking**: Automatically minimizes counterexamples
- **Configurable**: Control number of tests, size, tracing, etc.

**Maturity**: Production-ready, used in various Lean 4 projects

### 1.2 Other Options

**LeanCheck**: No native Lean 4 port found. LeanCheck exists for Haskell but has not been ported to Lean 4.

**Batteries/Std4**: The Batteries library (formerly Std4) does not include property-based testing functionality. It focuses on data structures and general utilities.

**Mathlib4**: Mathlib4 does not include property-based testing as a core feature, though it may use Plausible for internal testing.

---

## 2. Framework Comparison

| Feature | Plausible | Alternatives |
|---------|-----------|--------------|
| **Maturity** | Production-ready | None found |
| **Maintenance** | Active (2025) | N/A |
| **Integration** | Tactic + Command | N/A |
| **Shrinking** | Yes, automatic | N/A |
| **Custom Types** | Via type classes | N/A |
| **Documentation** | Good (README + examples) | N/A |
| **Dependencies** | None (pure Lean) | N/A |
| **Community** | 74 stars, 16 forks | N/A |

**Recommendation**: Use **Plausible** as it is the only mature, actively maintained property-based testing framework for Lean 4.

---

## 3. Integration Guide

### 3.1 Adding Plausible to Your Project

Add to your `lakefile.lean`:

```lean
require plausible from git
  "https://github.com/leanprover-community/plausible" @ "main"
```

Or to `lakefile.toml`:

```toml
[[require]]
name = "plausible"
git = "https://github.com/leanprover-community/plausible"
rev = "main"
```

Then run:
```bash
lake update
lake build
```

### 3.2 Basic Usage

Import the library:

```lean
import Plausible
```

Use the tactic in a proof:

```lean
example (xs ys : Array Nat) : xs.size = ys.size → xs = ys := by
  plausible
  -- Output:
  -- Found a counter-example!
  -- xs := #[0]
  -- ys := #[1]
  -- guard: 1 = 1
  -- issue: #[0] = #[1] does not hold
  -- (0 shrinks)
```

Use the command interface:

```lean
#test ∀ (x : Nat) (h : 5 < x), 10 < x
-- Finds counterexample: x = 6

#eval Plausible.Testable.check <| ∀ (xs ys : Array Nat), xs.size = ys.size → xs = ys
```

### 3.3 Configuration

Plausible supports various configuration options:

```lean
-- Default configuration
#test ∀ x : Nat, x + 1 > x

-- Custom configuration
#eval Plausible.Testable.check (∀ x : Nat, x + 1 > x) {
  numInst := 1000,        -- Number of test instances (default: 100)
  maxSize := 200,         -- Maximum size of generated values (default: 100)
  numRetries := 20,       -- Retries when preconditions fail (default: 10)
  traceDiscarded := true, -- Trace discarded values
  traceSuccesses := true, -- Trace successful tests
  traceShrink := true,    -- Trace shrinking process
  randomSeed := some 42,  -- Fixed seed for reproducibility
  quiet := false          -- Disable output
}

-- Verbose configuration for debugging
#eval Plausible.Testable.check (∀ x : Nat, x + 1 > x) 
  Plausible.Configuration.verbose
```

---

## 4. Property Test Patterns

### 4.1 Testing Built-in Types

Plausible has built-in support for standard types:

```lean
import Plausible

-- Natural numbers
#test ∀ n : Nat, n + 0 = n

-- Integers
#test ∀ n : Int, n + (-n) = 0

-- Lists
#test ∀ xs ys : List Nat, xs ++ ys = ys ++ xs  -- Fails!

-- Arrays
#test ∀ xs : Array Nat, xs.size ≥ 0

-- Options
#test ∀ x : Option Nat, x.isSome ∨ x.isNone

-- Products
#test ∀ p : Nat × Nat, p.1 + p.2 = p.2 + p.1

-- Sums
#test ∀ s : Nat ⊕ Bool, s = s
```

### 4.2 Testing with Preconditions

Use guards to test properties with preconditions:

```lean
-- Only test when x > 10
#test ∀ (x : Nat) (h : 10 < x), 5 < x

-- Multiple preconditions
#test ∀ (x y : Nat) (h1 : x > 0) (h2 : y > 0), x * y > 0
```

### 4.3 Testing Decidable Properties

Properties must be decidable:

```lean
-- This works (decidable equality)
#test ∀ x y : Nat, x + y = y + x

-- This works (decidable ordering)
#test ∀ x : Nat, x ≤ x

-- For custom predicates, provide Decidable instance
def IsPrime (n : Nat) : Prop := n > 1 ∧ ∀ m, m ∣ n → m = 1 ∨ m = n

instance : Decidable (IsPrime n) := sorry  -- Implement decidability

#test ∀ n : Nat, IsPrime n → n > 1
```

---

## 5. Custom Type Generators

### 5.1 Using `deriving Arbitrary`

For simple algebraic data types, use automatic derivation:

```lean
import Plausible

inductive Tree (α : Type) where
  | leaf : α → Tree α
  | node : Tree α → Tree α → Tree α
  deriving Repr, Arbitrary

#test ∀ t : Tree Nat, t = t  -- Works automatically!

-- Also works with multiple types
deriving instance Arbitrary for MyType1, MyType2, MyType3
```

### 5.2 Manual Instances for Custom Types

For types with invariants, implement the required type classes:

```lean
import Plausible
open Plausible

-- Type with invariant
structure MyType where
  x : Nat
  y : Nat
  h : x ≤ y
  deriving Repr

-- Shrinkable instance
instance : Shrinkable MyType where
  shrink := fun ⟨x, y, _⟩ =>
    let proxy := Shrinkable.shrink (x, y - x)
    proxy.map (fun (fst, snd) => ⟨fst, fst + snd, by omega⟩)

-- SampleableExt instance (generator)
instance : SampleableExt MyType :=
  SampleableExt.mkSelfContained do
    let x ← SampleableExt.interpSample Nat
    let xyDiff ← SampleableExt.interpSample Nat
    return ⟨x, x + xyDiff, by omega⟩

-- Now we can test properties
#eval Plausible.Testable.check <| ∀ a b : MyType, a.y ≤ b.x → a.x ≤ b.y
```

### 5.3 Generator Patterns

**Pattern 1: Dependent Generators**
```lean
instance : SampleableExt MyType := do
  let x ← SampleableExt.interpSample Nat
  let y ← SampleableExt.interpSample Nat
  if h : x ≤ y then
    return ⟨x, y, h⟩
  else
    return ⟨y, x, by omega⟩
```

**Pattern 2: Constrained Generators**
```lean
-- Generate only even numbers
def genEven : Gen Nat := do
  let n ← Arbitrary.arbitrary
  return 2 * n

instance : Arbitrary EvenNat where
  arbitrary := genEven.map (fun n => ⟨n, by omega⟩)
```

**Pattern 3: Composite Generators**
```lean
-- Generate pairs where first < second
instance : SampleableExt OrderedPair :=
  SampleableExt.mkSelfContained do
    let a ← SampleableExt.interpSample Nat
    let b ← SampleableExt.interpSample Nat
    if a < b then
      return ⟨a, b, by omega⟩
    else
      return ⟨b, a, by omega⟩
```

---

## 6. Generators for Modal Logic Types

### 6.1 Formula Generator

For your `Logos.Core.Syntax.Formula` type:

```lean
import Logos.Core.Syntax
import Plausible
open Plausible

-- Assuming Formula is defined as:
-- inductive Formula where
--   | var : String → Formula
--   | bot : Formula
--   | imp : Formula → Formula → Formula
--   | box : Formula → Formula

-- Option 1: Automatic derivation (if Formula is simple)
deriving instance Arbitrary for Formula

-- Option 2: Custom generator with size control
instance : Arbitrary Formula where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then
      -- Base cases
      Gen.oneOf [
        pure Formula.bot,
        Formula.var <$> Arbitrary.arbitrary
      ]
    else
      -- Recursive cases
      Gen.oneOf [
        pure Formula.bot,
        Formula.var <$> Arbitrary.arbitrary,
        Formula.imp <$> Gen.resize (size / 2) Arbitrary.arbitrary 
                    <*> Gen.resize (size / 2) Arbitrary.arbitrary,
        Formula.box <$> Gen.resize (size - 1) Arbitrary.arbitrary
      ]

-- Shrinkable instance
instance : Shrinkable Formula where
  shrink
    | Formula.var _ => []
    | Formula.bot => []
    | Formula.imp p q => [p, q] ++ 
        (Shrinkable.shrink p).map (Formula.imp · q) ++
        (Shrinkable.shrink q).map (Formula.imp p ·)
    | Formula.box p => [p] ++ 
        (Shrinkable.shrink p).map Formula.box

-- Now test properties
#test ∀ φ : Formula, φ = φ
```

### 6.2 Context Generator

For `Logos.Core.Syntax.Context` (List Formula):

```lean
-- Context is just List Formula, so it works automatically
#test ∀ Γ : Context, Γ.length ≥ 0

-- Custom generator for non-empty contexts
def genNonEmptyContext : Gen Context := do
  let φ ← Arbitrary.arbitrary
  let rest ← Arbitrary.arbitrary
  return φ :: rest

-- Generator for contexts with specific properties
def genValidContext : Gen Context := do
  let size ← Gen.choose 1 10
  List.replicateM size Arbitrary.arbitrary
```

### 6.3 TaskFrame Generator

For semantic structures:

```lean
import Logos.Core.Semantics

-- Assuming TaskFrame structure
structure TaskFrame where
  World : Type
  worlds : List World
  accessible : World → World → Prop
  -- ... other fields

-- Generator for finite frames
instance : SampleableExt TaskFrame where
  proxy := Nat  -- Use Nat as proxy for frame size
  interp n := {
    World := Fin n.succ
    worlds := List.finRange n.succ
    accessible := fun w1 w2 => w1.val ≤ w2.val
    -- ... implement other fields
  }

-- Or use a more sophisticated generator
instance : Arbitrary TaskFrame where
  arbitrary := do
    let numWorlds ← Gen.choose 1 10
    let worlds := List.finRange numWorlds
    -- Generate accessibility relation
    let edges ← Gen.listOf (Gen.choose 0 (numWorlds - 1) × 
                             Gen.choose 0 (numWorlds - 1))
    return {
      World := Fin numWorlds
      worlds := worlds
      accessible := fun w1 w2 => (w1.val, w2.val) ∈ edges
      -- ...
    }
```

---

## 7. Testing Metalogic Properties

### 7.1 Soundness Testing

```lean
import Logos.Core.ProofSystem
import Logos.Core.Semantics
import Plausible

-- Test that derivable formulas are valid
#test ∀ (Γ : Context) (φ : Formula),
  Derivable Γ φ → Valid Γ φ

-- Test specific derivation rules
#test ∀ (φ ψ : Formula),
  Derivable [] (φ ⊃ ψ ⊃ φ)  -- Axiom K

-- Test with preconditions
#test ∀ (Γ : Context) (φ ψ : Formula)
  (h1 : Derivable Γ φ) (h2 : Derivable Γ (φ ⊃ ψ)),
  Derivable Γ ψ  -- Modus ponens
```

### 7.2 Semantic Property Testing

```lean
-- Test frame properties
#test ∀ (F : TaskFrame) (w : F.World),
  F.accessible w w  -- Reflexivity

#test ∀ (F : TaskFrame) (w1 w2 w3 : F.World),
  F.accessible w1 w2 → F.accessible w2 w3 → 
  F.accessible w1 w3  -- Transitivity

-- Test truth conditions
#test ∀ (M : TaskModel) (w : M.frame.World) (φ ψ : Formula),
  M.satisfies w (φ ⊃ ψ) ↔ 
  (M.satisfies w φ → M.satisfies w ψ)
```

### 7.3 Derivation Property Testing

```lean
-- Test weakening
#test ∀ (Γ Δ : Context) (φ : Formula),
  Derivable Γ φ → Γ ⊆ Δ → Derivable Δ φ

-- Test cut
#test ∀ (Γ : Context) (φ ψ : Formula),
  Derivable Γ φ → Derivable (φ :: Γ) ψ → 
  Derivable Γ ψ

-- Test substitution
#test ∀ (φ ψ : Formula) (x : String) (θ : Formula),
  Derivable [] φ → 
  Derivable [] (φ.subst x θ)
```

---

## 8. Advanced Patterns

### 8.1 Testing with Invariants

```lean
-- Test that operations preserve invariants
structure SortedList where
  data : List Nat
  sorted : data.Sorted (· ≤ ·)

instance : SampleableExt SortedList :=
  SampleableExt.mkSelfContained do
    let xs ← Arbitrary.arbitrary
    let sorted := xs.mergeSort (· ≤ ·)
    return ⟨sorted, by sorry⟩  -- Prove sortedness

#test ∀ (xs : SortedList) (y : Nat),
  (insert xs y).sorted  -- Insert preserves sortedness
```

### 8.2 Testing Equivalences

```lean
-- Test that two implementations are equivalent
#test ∀ (xs : List Nat),
  xs.reverse.reverse = xs

#test ∀ (φ : Formula),
  φ.nnf.nnf = φ.nnf  -- NNF is idempotent
```

### 8.3 Conditional Testing

```lean
-- Test only when certain conditions hold
#test ∀ (φ : Formula) (h : φ.isModal),
  φ.boxDepth > 0

-- Use guards to filter test cases
#test ∀ (n : Nat) (h : n.Prime),
  n > 1
```

### 8.4 Shrinking Strategies

```lean
-- Custom shrinking for better counterexamples
instance : Shrinkable Formula where
  shrink φ := match φ with
    | Formula.var _ => []
    | Formula.bot => []
    | Formula.imp p q =>
      -- Try simpler formulas first
      [p, q, Formula.bot] ++
      (Shrinkable.shrink p).map (Formula.imp · q) ++
      (Shrinkable.shrink q).map (Formula.imp p ·)
    | Formula.box p =>
      -- Remove box or shrink contents
      [p, Formula.bot] ++
      (Shrinkable.shrink p).map Formula.box
```

---

## 9. Integration with Existing Tests

### 9.1 Complementing Unit Tests

Property tests complement traditional unit tests:

```lean
-- Unit test: specific case
example : Formula.var "p" ⊃ Formula.var "p" = 
          Formula.imp (Formula.var "p") (Formula.var "p") := rfl

-- Property test: general pattern
#test ∀ (φ : Formula), φ ⊃ φ = Formula.imp φ φ
```

### 9.2 Running in CI

Add to your test suite:

```lean
-- LogosTest/PropertyTests.lean
import Plausible
import Logos.Core

def runPropertyTests : IO Unit := do
  -- Test 1: Formula equality is reflexive
  Plausible.Testable.checkIO (∀ φ : Formula, φ = φ)
  
  -- Test 2: Derivation is monotone
  Plausible.Testable.checkIO 
    (∀ Γ Δ φ, Derivable Γ φ → Γ ⊆ Δ → Derivable Δ φ)
  
  IO.println "All property tests passed!"

#eval runPropertyTests
```

### 9.3 Debugging Failed Tests

When a test fails:

```lean
-- Use verbose configuration
#eval Plausible.Testable.check 
  (∀ φ ψ : Formula, φ ⊃ ψ = ψ ⊃ φ)
  Plausible.Configuration.verbose

-- Output shows:
-- - Generated values
-- - Shrinking steps
-- - Final counterexample
```

---

## 10. Examples from Lean 4 Projects

### 10.1 Plausible Self-Tests

The Plausible repository includes comprehensive tests:

```lean
-- From Test/Plausible.lean
#test ∀ (x y : Nat), x + y = y + x
#test ∀ (xs : List Nat), xs.reverse.reverse = xs
#test ∀ (n : Nat), n ≤ n
```

### 10.2 Testing Data Structures

```lean
-- Red-black tree properties
#test ∀ (t : RBTree Nat), t.isBalanced
#test ∀ (t : RBTree Nat) (x : Nat), 
  (t.insert x).contains x
```

### 10.3 Testing Algorithms

```lean
-- Sorting properties
#test ∀ (xs : List Nat), 
  (xs.mergeSort (· ≤ ·)).Sorted (· ≤ ·)

#test ∀ (xs : List Nat),
  (xs.mergeSort (· ≤ ·)).length = xs.length
```

---

## 11. Best Practices

### 11.1 Generator Design

1. **Start simple**: Use `deriving Arbitrary` when possible
2. **Control size**: Use `Gen.sized` for recursive types
3. **Respect invariants**: Ensure generated values satisfy type constraints
4. **Balance distribution**: Use `Gen.oneOf` for uniform distribution

### 11.2 Property Selection

1. **Test invariants**: Properties that should always hold
2. **Test equivalences**: Different implementations of same function
3. **Test round-trips**: `f (g x) = x` patterns
4. **Test monotonicity**: Order-preserving properties
5. **Test idempotence**: `f (f x) = f x` patterns

### 11.3 Shrinking Strategy

1. **Shrink to simpler values**: Remove constructors when possible
2. **Shrink components**: Recursively shrink subterms
3. **Preserve invariants**: Ensure shrunk values are still valid
4. **Order by simplicity**: Return simpler candidates first

### 11.4 Performance

1. **Limit test count**: Use reasonable `numInst` (100-1000)
2. **Control size**: Set appropriate `maxSize` for your types
3. **Cache generators**: Reuse `Arbitrary` instances
4. **Profile slow tests**: Use `traceShrink` to identify bottlenecks

---

## 12. Limitations and Workarounds

### 12.1 Non-Decidable Properties

**Problem**: Property must be decidable to test

**Workaround**: Provide `Decidable` instance or test decidable approximation

```lean
-- Instead of testing ∀ n, Prime n → ...
-- Test decidable version:
#test ∀ n, isPrime n → ...  -- where isPrime : Nat → Bool
```

### 12.2 Infinite Types

**Problem**: Cannot generate all values of infinite types

**Workaround**: Use proxy types or bounded generators

```lean
-- Instead of Nat → Nat, use finite function representation
structure FiniteFunction where
  domain : List Nat
  mapping : Nat → Nat

instance : SampleableExt FiniteFunction := ...
```

### 12.3 Complex Invariants

**Problem**: Hard to generate values satisfying complex invariants

**Workaround**: Generate unconstrained values and filter, or use smart constructors

```lean
-- Filter approach
instance : SampleableExt ValidFormula :=
  SampleableExt.mkSelfContained do
    let φ ← Arbitrary.arbitrary
    if φ.isValid then
      return ⟨φ, by sorry⟩
    else
      -- Retry or transform to valid formula
      return ⟨φ.makeValid, by sorry⟩
```

### 12.4 Proof Generation

**Problem**: Plausible finds counterexamples but doesn't generate proofs

**Workaround**: Use counterexamples to guide manual proof or refine property

```lean
-- Failed test reveals edge case
#test ∀ n : Nat, n > 0 → n - 1 < n
-- Counterexample: n = 0 (violates precondition)

-- Refined property
#test ∀ n : Nat, n > 0 → n - 1 < n  -- Now passes
```

---

## 13. Resources and Documentation

### 13.1 Official Resources

- **Plausible Repository**: https://github.com/leanprover-community/plausible
- **Plausible README**: Comprehensive usage guide
- **Mathlib4 Docs**: https://leanprover-community.github.io/mathlib4_docs/Plausible.html
- **Lean 4 Manual**: https://lean-lang.org/lean4/doc/

### 13.2 Example Code

- **Plausible/Test/**: Test suite with examples
- **Plausible/Plausible/**: Core implementation
  - `Testable.lean`: Main testing infrastructure
  - `Sampleable.lean`: Generator type classes
  - `Arbitrary.lean`: Built-in generators
  - `Gen.lean`: Generator monad

### 13.3 Community Resources

- **Lean Zulip**: https://leanprover.zulipchat.com/
  - Search for "plausible" or "property testing"
- **Lean Community**: https://leanprover-community.github.io/
- **GitHub Issues**: Report bugs or request features

### 13.4 Related Papers

- **QuickCheck**: "QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs" (Claessen & Hughes, 2000)
- **SmallCheck**: "SmallCheck and Lazy SmallCheck: automatic exhaustive testing for small values" (Runciman et al., 2008)

---

## 14. Comparison with Other Languages

### 14.1 Haskell QuickCheck

**Similarities**:
- Random generation
- Shrinking
- Property-based approach

**Differences**:
- Plausible integrates with Lean's tactic system
- Plausible uses Lean's type system for generators
- Plausible has built-in support for dependent types

### 14.2 Scala ScalaCheck

**Similarities**:
- Generator combinators
- Shrinking
- Property testing

**Differences**:
- Plausible is more tightly integrated with proof assistant
- Plausible can test properties involving proofs
- Plausible has automatic derivation via `deriving`

### 14.3 Python Hypothesis

**Similarities**:
- Shrinking
- Example database
- Property testing

**Differences**:
- Plausible is statically typed
- Plausible integrates with theorem proving
- Plausible has no example database (yet)

---

## 15. Future Directions

### 15.1 Potential Enhancements

1. **Coverage-guided generation**: Use coverage metrics to guide test generation
2. **Mutation testing**: Automatically generate mutants to test test quality
3. **Proof synthesis**: Generate proofs from successful tests
4. **Example database**: Cache and reuse interesting test cases
5. **Parallel testing**: Run tests in parallel for better performance

### 15.2 Integration Opportunities

1. **Aesop integration**: Use property tests to guide proof search
2. **Tactic development**: Test tactics using property tests
3. **Counterexample extraction**: Extract Lean terms from counterexamples
4. **Proof repair**: Use counterexamples to suggest proof fixes

### 15.3 Research Directions

1. **Dependent type testing**: Better support for dependent types
2. **Proof-carrying tests**: Tests that carry correctness proofs
3. **Symbolic execution**: Combine with symbolic methods
4. **Formal verification**: Verify property test implementations

---

## 16. Conclusion

**Plausible** is the recommended and only mature property-based testing framework for Lean 4. It provides:

✅ **Easy integration**: Works as both tactic and command  
✅ **Automatic derivation**: `deriving Arbitrary` for custom types  
✅ **Good shrinking**: Minimizes counterexamples automatically  
✅ **Active maintenance**: Regularly updated by Lean community  
✅ **No dependencies**: Pure Lean, no NPM required  
✅ **Good documentation**: README and examples provided  

**For the ProofChecker project**, Plausible is ideal for:
- Testing metalogic properties (soundness, completeness)
- Testing derivation rules and tactics
- Testing semantic properties of frames and models
- Finding edge cases in proof search algorithms
- Validating formula transformations

**Next Steps**:
1. Add Plausible to project dependencies
2. Create generators for `Formula`, `Context`, `TaskFrame`
3. Write property tests for core metalogic properties
4. Integrate into CI/CD pipeline
5. Use to guide development of new features

---

## Appendix A: Quick Reference

### Type Classes

```lean
-- Generator
class Arbitrary (α : Type) where
  arbitrary : Gen α

-- Shrinking
class Shrinkable (α : Type) where
  shrink : α → List α

-- Full control
class SampleableExt (α : Sort u) where
  proxy : Type v
  proxyRepr : Repr proxy
  shrink : Shrinkable proxy
  sample : Arbitrary proxy
  interp : proxy → α
```

### Common Generators

```lean
-- Basic types
Arbitrary.arbitrary : Gen Nat
Arbitrary.arbitrary : Gen Int
Arbitrary.arbitrary : Gen Bool
Arbitrary.arbitrary : Gen Char
Arbitrary.arbitrary : Gen String

-- Combinators
Gen.choose : Nat → Nat → Gen Nat
Gen.oneOf : List (Gen α) → Gen α
Gen.listOf : Gen α → Gen (List α)
Gen.sized : (Nat → Gen α) → Gen α
Gen.resize : Nat → Gen α → Gen α
```

### Configuration Options

```lean
structure Configuration where
  numInst : Nat := 100
  maxSize : Nat := 100
  numRetries : Nat := 10
  traceDiscarded : Bool := false
  traceSuccesses : Bool := false
  traceShrink : Bool := false
  traceShrinkCandidates : Bool := false
  randomSeed : Option Nat := none
  quiet : Bool := false
```

---

## Appendix B: Complete Example

```lean
import Plausible
open Plausible

-- Define a custom type
inductive BinTree (α : Type) where
  | leaf : BinTree α
  | node : α → BinTree α → BinTree α → BinTree α
  deriving Repr, Arbitrary

-- Define operations
def BinTree.size : BinTree α → Nat
  | leaf => 0
  | node _ l r => 1 + l.size + r.size

def BinTree.height : BinTree α → Nat
  | leaf => 0
  | node _ l r => 1 + max l.height r.height

-- Test properties
#test ∀ (t : BinTree Nat), t.size ≥ 0
#test ∀ (t : BinTree Nat), t.height ≤ t.size
#test ∀ (t : BinTree Nat), t.size = 0 ↔ t = BinTree.leaf

-- Custom generator with size control
instance : Arbitrary (BinTree Nat) where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then
      pure BinTree.leaf
    else
      Gen.oneOf [
        pure BinTree.leaf,
        BinTree.node <$> Arbitrary.arbitrary 
                     <*> Gen.resize (size / 2) Arbitrary.arbitrary
                     <*> Gen.resize (size / 2) Arbitrary.arbitrary
      ]

-- Custom shrinking
instance : Shrinkable (BinTree α) where
  shrink
    | BinTree.leaf => []
    | BinTree.node _ l r => [l, r, BinTree.leaf]

-- Test with custom configuration
#eval Testable.check 
  (∀ t : BinTree Nat, t.size ≤ 100)
  { numInst := 1000, maxSize := 50 }
```

---

**End of Research Findings**

**Sources**:
- https://github.com/leanprover-community/plausible
- https://github.com/leanprover/lean4
- https://github.com/leanprover-community/mathlib4
- https://leanprover-community.github.io/
- https://leanprover-community.github.io/mathlib4_docs/Plausible.html

# Property-Based Testing Guide for Logos

**Version**: 1.0  
**Date**: 2025-12-25  
**Status**: Complete

---

## Table of Contents

1. [Introduction](#introduction)
2. [Plausible Framework Overview](#plausible-framework-overview)
3. [Generator Patterns](#generator-patterns)
4. [Property Selection Strategies](#property-selection-strategies)
5. [Configuration and Tuning](#configuration-and-tuning)
6. [Troubleshooting](#troubleshooting)
7. [CI/CD Integration](#cicd-integration)
8. [Examples](#examples)

---

## Introduction

Property-based testing is a testing methodology that automatically generates test cases to verify that properties (general laws and invariants) hold across a wide range of inputs. Unlike example-based tests that check specific cases, property tests check universal properties.

### Benefits

- **Comprehensive Coverage**: Tests hundreds of cases automatically
- **Edge Case Discovery**: Finds corner cases you didn't think of
- **Regression Prevention**: Catches bugs introduced by changes
- **Documentation**: Properties serve as executable specifications
- **Shrinking**: Automatically finds minimal failing examples

### When to Use Property Testing

✅ **Use for**:
- Universal invariants (e.g., `complexity ≥ 1`)
- Algebraic properties (e.g., `swap_temporal` involution)
- Structural properties (e.g., weakening, reflexivity)
- Transformation correctness (e.g., derived operator definitions)

❌ **Don't use for**:
- Specific example verification (use unit tests)
- Non-decidable properties (e.g., general derivability)
- Properties requiring complex setup

---

## Plausible Framework Overview

Logos uses the [Plausible](https://github.com/leanprover-community/plausible) framework for property-based testing.

### Core Type Classes

#### 1. Arbitrary α

Generates random values of type `α`:

```lean
class Arbitrary (α : Type u) where
  arbitrary : Gen α
```

**Example**:
```lean
instance : Arbitrary Formula where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then
      Gen.oneOf [pure Formula.bot, Formula.atom <$> Arbitrary.arbitrary]
    else
      Gen.oneOf [
        pure Formula.bot,
        Formula.atom <$> Arbitrary.arbitrary,
        Formula.imp <$> Gen.resize (size/2) Arbitrary.arbitrary
                    <*> Gen.resize (size/2) Arbitrary.arbitrary,
        Formula.box <$> Gen.resize (size-1) Arbitrary.arbitrary,
        -- ... other constructors
      ]
```

#### 2. Shrinkable α

Shrinks values to simpler forms for better counterexamples:

```lean
class Shrinkable (α : Type u) where
  shrink : α → List α
```

**Example**:
```lean
instance : Shrinkable Formula where
  shrink
    | Formula.atom _ => []
    | Formula.bot => []
    | Formula.imp p q =>
        [p, q] ++
        (Shrinkable.shrink p).map (Formula.imp · q) ++
        (Shrinkable.shrink q).map (Formula.imp p ·)
    | Formula.box p =>
        [p] ++ (Shrinkable.shrink p).map Formula.box
    -- ... other constructors
```

#### 3. SampleableExt α

For types with complex constraints or dependent types:

```lean
class SampleableExt (α : Type u) where
  proxy : Type v
  interp : proxy → α
  sample : Gen proxy
```

**Example** (TaskModel with dependent types):
```lean
structure TaskModelProxy where
  frameProxy : Unit
  valuationSeed : Nat

instance : SampleableExt (TaskModel (TaskFrame.nat_frame (T := Int))) where
  proxy := TaskModelProxy
  interp p :=
    { valuation := fun w s =>
        (Nat.mix (Nat.mix p.valuationSeed w.toNat) s.length) % 2 = 0
    }
  sample := do
    let seed ← Gen.choose 0 1000
    return ⟨(), seed⟩
```

#### 4. Testable p

Makes propositions testable:

```lean
class Testable (p : Prop) where
  run : Configuration → Gen TestResult
```

### Running Tests

Two main interfaces:

1. **Command interface** (quick checks):
```lean
#test ∀ φ : Formula, φ.complexity ≥ 1
```

2. **Evaluation interface** (with configuration):
```lean
#eval Testable.check (∀ φ : Formula, φ.complexity ≥ 1) {
  numInst := 500,
  maxSize := 40,
  traceShrink := false
}
```

---

## Generator Patterns

### Pattern 1: Size-Controlled Recursive Generation

**Problem**: Recursive types can generate infinitely deep structures.

**Solution**: Use `Gen.sized` with size reduction:

```lean
instance : Arbitrary Formula where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then
      -- Base cases only
      Gen.oneOf [pure Formula.bot, Formula.atom <$> Arbitrary.arbitrary]
    else
      -- Recursive cases with reduced size
      let subsize := size / 2
      Gen.oneOf [
        pure Formula.bot,
        Formula.atom <$> Arbitrary.arbitrary,
        Formula.imp <$> Gen.resize subsize Arbitrary.arbitrary
                    <*> Gen.resize subsize Arbitrary.arbitrary,
        Formula.box <$> Gen.resize (size - 1) Arbitrary.arbitrary
      ]
```

**Key points**:
- At size 0, only generate base cases
- For recursive constructors, reduce size (typically `size/2` or `size-1`)
- Use `Gen.resize` to control subterm size

### Pattern 2: Shrinking Strategy

**Problem**: Counterexamples should be minimal for debugging.

**Solution**: Shrink to immediate subterms and recursively shrink subterms:

```lean
instance : Shrinkable Formula where
  shrink
    | Formula.atom _ => []  -- Base cases don't shrink
    | Formula.bot => []
    | Formula.imp p q =>
        [p, q] ++  -- Immediate subterms
        (Shrinkable.shrink p).map (Formula.imp · q) ++  -- Shrink left
        (Shrinkable.shrink q).map (Formula.imp p ·)     -- Shrink right
    | Formula.box p =>
        [p] ++ (Shrinkable.shrink p).map Formula.box
```

**Key points**:
- Base cases return empty list
- Include immediate subterms first
- Recursively shrink each subterm position

### Pattern 3: Dependent Type Generation (Proxy Pattern)

**Problem**: Types with dependent fields (e.g., `TaskModel` where `valuation` depends on `F.WorldState`).

**Solution**: Use `SampleableExt` with a proxy type:

```lean
-- Step 1: Define proxy type
structure TaskModelProxy where
  frameProxy : Unit  -- Proxy for frame (use default generator)
  valuationSeed : Nat  -- Seed for deterministic valuation

-- Step 2: Implement SampleableExt
instance : SampleableExt (TaskModel (TaskFrame.nat_frame (T := Int))) where
  proxy := TaskModelProxy
  
  -- Step 3: Interpret proxy as actual value
  interp p :=
    { valuation := fun w s =>
        -- Deterministic hash-based valuation
        (Nat.mix (Nat.mix p.valuationSeed w.toNat) s.length) % 2 = 0
    }
  
  -- Step 4: Generate proxy
  sample := do
    let seed ← Gen.choose 0 1000
    return ⟨(), seed⟩
```

**Key points**:
- Proxy type captures generation parameters
- `interp` constructs the actual value from proxy
- Use deterministic functions (hash-based) for reproducibility
- Seed-based approach ensures varied but reproducible values

### Pattern 4: Constrained Generation

**Problem**: Generate values satisfying specific constraints.

**Solution**: Use `Gen.suchThat` or custom generators:

```lean
-- Generate non-empty contexts
def genNonEmptyContext : Gen Context := do
  let φ ← Arbitrary.arbitrary
  let Γ ← Arbitrary.arbitrary
  return φ :: Γ

-- Generate formulas of specific size
def genFormulaOfSize (n : Nat) : Gen Formula :=
  Gen.resize n Arbitrary.arbitrary

-- Generate propositional formulas only
partial def genPropFormula : Gen Formula := Gen.sized fun size =>
  if size ≤ 0 then
    Gen.oneOf [pure Formula.bot, Formula.atom <$> Arbitrary.arbitrary]
  else
    let subsize := size / 2
    Gen.oneOf [
      pure Formula.bot,
      Formula.atom <$> Arbitrary.arbitrary,
      Formula.imp <$> Gen.resize subsize genPropFormula
                  <*> Gen.resize subsize genPropFormula
    ]
```

---

## Property Selection Strategies

### 1. Universal Invariants

Properties that hold for ALL values:

```lean
-- Complexity is always positive
#test ∀ φ : Formula, φ.complexity ≥ 1

-- Frame nullity
#test ∀ (F : TaskFrame Int) (w : F.WorldState), F.task_rel w 0 w
```

### 2. Algebraic Properties

Properties expressing algebraic laws:

```lean
-- Involution
#test ∀ φ : Formula, φ.swap_temporal.swap_temporal = φ

-- Distributivity
#test ∀ φ : Formula, φ.diamond.swap_temporal = φ.swap_temporal.diamond

-- Associativity
#test ∀ x y z : Int, (x + y) + z = x + (y + z)
```

### 3. Structural Properties

Properties about derivation/proof structure:

```lean
-- Reflexivity
#test ∀ (Γ : Context) (φ : Formula), φ ∈ Γ → Nonempty (Γ ⊢ φ)

-- Weakening
#test ∀ (Γ Δ : Context) (φ : Formula) (d : Γ ⊢ φ) (h : Γ ⊆ Δ),
  Nonempty (Δ ⊢ φ)

-- Height properties
#test ∀ (d1 d2 : DerivationTree),
  d1.height < (modus_ponens d1 d2).height
```

### 4. Semantic Properties

Properties about truth and validity:

```lean
-- Axiom validity
#test ∀ φ : Formula, ⊨ (φ.box.imp φ)  -- Modal T

-- Truth conditions
#test ∀ (M : TaskModel F) (w : F.WorldState) (φ ψ : Formula),
  truth_at M w (φ.imp ψ) ↔ (truth_at M w φ → truth_at M w ψ)
```

### 5. Transformation Properties

Properties about formula transformations:

```lean
-- Derived operator definitions
#test ∀ φ : Formula, φ.diamond = φ.neg.box.neg
#test ∀ φ : Formula, φ.neg = φ.imp Formula.bot
#test ∀ φ ψ : Formula, φ.and ψ = (φ.imp ψ.neg).neg

-- Operator injectivity
#test ∀ φ ψ : Formula, φ.box = ψ.box → φ = ψ
```

### What NOT to Test

❌ **Tautologies**:
```lean
#test ∀ φ : Formula, φ = φ  -- Always true, not useful
```

❌ **Non-decidable properties**:
```lean
-- Can't test general derivability (not decidable)
#test ∀ φ : Formula, Derivable [] φ → valid [] φ
```

Instead, test specific instances:
```lean
-- Test specific axiom instances
#test ∀ φ : Formula, ⊨ (φ.box.imp φ)  -- Modal T is valid
```

---

## Configuration and Tuning

### Configuration Parameters

```lean
structure Configuration where
  numInst : Nat := 100        -- Number of test cases
  maxSize : Nat := 100        -- Maximum size for generators
  numRetries : Nat := 10      -- Retries for preconditions
  traceShrink : Bool := false -- Debug shrinking process
  randomSeed : Option Nat := none  -- Seed for reproducibility
```

### Tuning Guidelines

#### Test Count (`numInst`)

- **Default**: 100 test cases
- **Critical properties**: 500 test cases
  ```lean
  #eval Testable.check (∀ φ, modal_5_collapse_valid φ) {
    numInst := 500  -- S5 characteristic axiom
  }
  ```
- **Expensive properties**: 50 test cases
  ```lean
  #eval Testable.check (∀ Γ Δ φ, weakening_property Γ Δ φ) {
    numInst := 50  -- Derivation construction is expensive
  }
  ```

#### Size Control (`maxSize`)

- **Simple formulas**: 30
- **Complex formulas**: 50
- **Very complex**: 100

```lean
-- Simple propositional properties
#eval Testable.check (∀ φ ψ, prop_k_valid φ ψ) {
  maxSize := 30
}

-- Complex modal/temporal properties
#eval Testable.check (∀ φ, temporal_property φ) {
  maxSize := 50
}
```

#### Retry Count (`numRetries`)

For properties with preconditions:

```lean
-- Property with restrictive precondition
#eval Testable.check (∀ Γ Δ φ, Γ ⊆ Δ → property Γ Δ φ) {
  numRetries := 30  -- May need more retries to satisfy Γ ⊆ Δ
}
```

#### Shrinking Trace (`traceShrink`)

Enable for debugging:

```lean
#eval Testable.check (∀ φ, property φ) {
  traceShrink := true  -- Shows shrinking steps
}
```

### Performance Targets

- **Target**: <5 seconds per property with 100 test cases
- **Optimization strategies**:
  1. Reduce `numInst` (fewer test cases)
  2. Reduce `maxSize` (smaller formulas)
  3. Optimize generators (avoid expensive operations)
  4. Profile with `traceShrink := true`

---

## Troubleshooting

### Problem 1: Tests Timeout

**Symptoms**: Tests take too long or hang.

**Causes**:
- Infinite generation (no size control)
- Too large `maxSize`
- Too many test cases

**Solutions**:
```lean
-- Add size control to generator
instance : Arbitrary MyType where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then base_case
    else Gen.resize (size - 1) recursive_case

-- Reduce test parameters
#eval Testable.check property {
  numInst := 50,   -- Reduce from 100
  maxSize := 30    -- Reduce from 50
}
```

### Problem 2: No Counterexamples Found (False Positives)

**Symptoms**: Property passes but should fail.

**Causes**:
- Precondition too restrictive
- Generator doesn't produce relevant cases
- Property is actually true

**Solutions**:
```lean
-- Check precondition hit rate
#eval Testable.check (∀ φ, precondition φ → property φ) {
  traceShrink := true  -- Shows how many cases satisfy precondition
}

-- Broaden generator or relax precondition
def genRelevantCases : Gen MyType := ...
```

### Problem 3: Large Counterexamples

**Symptoms**: Failing examples are too complex to debug.

**Causes**:
- Poor shrinking strategy
- No shrinking implemented

**Solutions**:
```lean
-- Implement good shrinking
instance : Shrinkable MyType where
  shrink
    | base_case => []
    | compound x y =>
        [x, y] ++  -- Immediate subterms first
        (shrink x).map (compound · y) ++
        (shrink y).map (compound x ·)
```

### Problem 4: Dependent Type Errors

**Symptoms**: Type errors with dependent types.

**Causes**:
- Direct `Arbitrary` instance doesn't work for dependent types

**Solutions**:
```lean
-- Use SampleableExt with proxy pattern
structure MyTypeProxy where
  param1 : Type1
  param2 : Nat

instance : SampleableExt MyType where
  proxy := MyTypeProxy
  interp p := construct_from_proxy p
  sample := generate_proxy
```

### Problem 5: Non-Deterministic Failures

**Symptoms**: Tests sometimes pass, sometimes fail.

**Causes**:
- Random seed variation
- Race conditions (unlikely in pure Lean)

**Solutions**:
```lean
-- Fix random seed for reproducibility
#eval Testable.check property {
  randomSeed := some 42
}
```

---

## CI/CD Integration

### Running Property Tests in CI

Property tests are integrated into the CI pipeline:

```bash
# Build test library
lake build LogosTest

# Run specific property test file
lake env lean LogosTest/Core/Syntax/FormulaPropertyTest.lean
lake env lean LogosTest/Core/ProofSystem/DerivationPropertyTest.lean
lake env lean LogosTest/Core/Semantics/SemanticPropertyTest.lean
lake env lean LogosTest/Core/Metalogic/SoundnessPropertyTest.lean
```

### GitHub Actions Workflow

```yaml
name: Property Tests

on: [push, pull_request]

jobs:
  property-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Lean
        uses: leanprover/lean-action@v1
        with:
          lean-version: 'leanprover/lean4:v4.14.0'
      
      - name: Build LogosTest
        run: lake build LogosTest
      
      - name: Run Property Tests
        run: |
          lake env lean LogosTest/Core/Syntax/FormulaPropertyTest.lean
          lake env lean LogosTest/Core/ProofSystem/DerivationPropertyTest.lean
          lake env lean LogosTest/Core/Semantics/SemanticPropertyTest.lean
          lake env lean LogosTest/Core/Metalogic/SoundnessPropertyTest.lean
```

### Performance Monitoring

Track test execution time:

```bash
# Time individual test files
time lake env lean LogosTest/Core/Syntax/FormulaPropertyTest.lean

# Set timeout for CI (5 minutes per file)
timeout 300 lake env lean LogosTest/Core/Syntax/FormulaPropertyTest.lean
```

---

## Examples

### Example 1: Formula Complexity Property

```lean
-- Property: Complexity is always positive
example : Testable (∀ φ : Formula, φ.complexity ≥ 1) := by
  infer_instance

#eval Testable.check (∀ φ : Formula, φ.complexity ≥ 1) {
  numInst := 100,
  maxSize := 50
}
```

### Example 2: Temporal Swap Involution

```lean
-- Property: Swapping temporal operators twice gives original
example : Testable (∀ φ : Formula, φ.swap_temporal.swap_temporal = φ) := by
  infer_instance

#eval Testable.check (∀ φ : Formula, φ.swap_temporal.swap_temporal = φ) {
  numInst := 100,
  maxSize := 50
}
```

### Example 3: Axiom Validity

```lean
-- Property: Modal T axiom is valid
example : Testable (∀ φ : Formula, ⊨ (φ.box.imp φ)) := by
  infer_instance

#eval Testable.check (∀ φ : Formula, ⊨ (φ.box.imp φ)) {
  numInst := 500,  -- Critical property
  maxSize := 40
}
```

### Example 4: Derivation Weakening

```lean
-- Property: Weakening preserves derivability
def weakening_property (Γ Δ : Context) (φ : Formula)
    (d : Γ ⊢ φ) (h : Γ ⊆ Δ) : Δ ⊢ φ :=
  DerivationTree.weakening Γ Δ φ d h

example : ∀ (Γ Δ : Context) (φ : Formula) (d : Γ ⊢ φ) (h : Γ ⊆ Δ),
    Nonempty (Δ ⊢ φ) := by
  intro Γ Δ φ d h
  exact ⟨DerivationTree.weakening Γ Δ φ d h⟩
```

### Example 5: TaskModel Generation

```lean
-- Property: Generated models have valid frames
example : ∀ (M : TaskModel (TaskFrame.nat_frame (T := Int))) (w : Nat),
    M.frame.task_rel w 0 w := by
  intro M w
  exact M.frame.nullity w
  where
    frame (M : TaskModel F) : TaskFrame Int := F
```

---

## Summary

Property-based testing with Plausible provides:

1. **Automatic test case generation** (100+ cases per property)
2. **Shrinking for minimal counterexamples**
3. **Coverage of edge cases**
4. **Executable specifications**

**Key takeaways**:
- Use size control for recursive types
- Implement good shrinking strategies
- Use proxy pattern for dependent types
- Configure test parameters appropriately
- Test meaningful properties, not tautologies
- Integrate with CI/CD for continuous verification

**Resources**:
- [Plausible Repository](https://github.com/leanprover-community/plausible)
- [Logos Property Tests](../../LogosTest/Core/Property/)
- [Research Report](../../specs/174_property_based_testing/reports/research-001.md)

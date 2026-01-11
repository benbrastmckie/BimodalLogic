# Property-Based Testing for Logos

This directory contains property-based tests for the Logos proof checker using the Plausible framework.

## Overview

Property-based testing automatically generates test cases to verify that properties hold across a wide range of inputs. Unlike example-based tests that check specific cases, property tests check general laws and invariants.

## Structure

- **Generators.lean**: Type generators for Formula, Context, TaskFrame, TaskModel
- **FormulaPropertyTest.lean**: Formula transformation properties (✅ implemented)
- **DerivationPropertyTest.lean**: Derivation system properties (✅ implemented)
- **SemanticPropertyTest.lean**: Semantic properties (✅ implemented)
- **SoundnessPropertyTest.lean**: Metalogic soundness properties (✅ implemented)

## Property Test Patterns

### 1. Universal Properties

Properties that should hold for ALL inputs:

```lean
-- Complexity is always positive
#test ∀ φ : Formula, φ.complexity > 0

-- Reflexivity
#test ∀ (Γ : Context) (φ : Formula), φ ∈ Γ → Derivable Γ φ
```

### 2. Conditional Properties

Properties with preconditions:

```lean
-- Weakening
#test ∀ (Γ Δ : Context) (φ : Formula),
  Derivable Γ φ → Γ ⊆ Δ → Derivable Δ φ
```

### 3. Equivalence Properties

Properties asserting equivalence:

```lean
-- Double negation
#test ∀ φ : Formula, semantically_equivalent φ φ.neg.neg
```

### 4. Invariant Properties

Properties that are preserved by transformations:

```lean
-- Swap temporal is involution
#test ∀ φ : Formula, φ.swap_temporal.swap_temporal = φ
```

## Generator Patterns

### Size-Controlled Generation

For recursive types like Formula:

```lean
instance : Arbitrary Formula where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then
      Gen.oneOf [base_cases]
    else
      Gen.oneOf [base_cases ++ recursive_cases_with_reduced_size]
```

### Shrinking Strategy

For better counterexamples:

```lean
instance : Shrinkable Formula where
  shrink
    | base_case => []
    | compound p q => [p, q] ++ shrink_subformulas
```

### Constrained Generation

For types with invariants:

```lean
instance : SampleableExt MyType where
  proxy := SomeType
  interp x := construct_valid_instance x
  sample := generate_proxy
```

### TaskModel Generator (Dependent Types)

For types with dependent fields like TaskModel:

```lean
-- TaskModel has: valuation : F.WorldState → String → Prop
-- Use proxy pattern to handle dependency

structure TaskModelProxy where
  frameProxy : Unit
  valuationSeed : Nat

instance : SampleableExt (TaskModel (TaskFrame.nat_frame (T := Int))) where
  proxy := TaskModelProxy
  interp p :=
    { valuation := fun w s =>
        -- Deterministic hash-based valuation
        (Nat.mix (Nat.mix p.valuationSeed w.toNat) s.length) % 2 = 0
    }
  sample := do
    let seed ← Gen.choose 0 1000
    return ⟨(), seed⟩
```

This pattern:
1. Generates the frame first (via Unit proxy)
2. Creates a deterministic valuation based on a seed
3. Uses hash function for varied but reproducible truth values

## Configuration

Property tests can be configured with:

```lean
#eval Plausible.Testable.check (∀ φ : Formula, property φ) {
  numInst := 100,        -- Number of test cases
  maxSize := 50,         -- Maximum formula size
  numRetries := 20,      -- Retries for preconditions
  traceShrink := false,  -- Debug shrinking
  randomSeed := none     -- Reproducibility
}
```

## Best Practices

1. **Start Simple**: Begin with simple properties before complex ones
2. **Size Control**: Always use size control for recursive generators
3. **Good Shrinking**: Implement shrinking for better counterexamples
4. **Meaningful Properties**: Test actual invariants, not tautologies
5. **Precondition Balance**: Avoid overly restrictive preconditions
6. **Coverage**: Aim for 100+ test cases per property

## Common Pitfalls

### Infinite Generation

❌ **Bad**: No size control
```lean
arbitrary := Formula.imp <$> arbitrary <*> arbitrary
```

✅ **Good**: Size-controlled
```lean
arbitrary := Gen.sized fun size =>
  if size ≤ 0 then base_case
  else Formula.imp <$> Gen.resize (size/2) arbitrary
                   <*> Gen.resize (size/2) arbitrary
```

### Trivial Properties

❌ **Bad**: Tautology
```lean
#test ∀ φ : Formula, φ = φ  -- Always true, not useful
```

✅ **Good**: Meaningful property
```lean
#test ∀ φ : Formula, φ.complexity ≥ 1  -- Actual invariant
```

### Over-Constrained Preconditions

❌ **Bad**: Too specific
```lean
#test ∀ φ, φ = Formula.bot → property φ  -- Only tests one case
```

✅ **Good**: General precondition
```lean
#test ∀ φ, φ.complexity < 10 → property φ  -- Tests many cases
```

## Testing Workflow

1. **Write Property**: Define the property to test
2. **Generate Inputs**: Use Arbitrary instances
3. **Run Tests**: Execute with `#test` or `#eval`
4. **Analyze Failures**: Use shrinking to find minimal counterexample
5. **Fix or Refine**: Either fix the code or refine the property

## Integration with CI

Property tests run automatically in CI:

```bash
# Run all property tests
lake test BimodalTest.Property

# Run specific property test file
lake env lean BimodalTest/Property/FormulaPropertyTest.lean
```

## Performance

Property tests are more expensive than unit tests:

- **Target**: <5 seconds per property with 100 test cases
- **Optimization**: Reduce `numInst` or `maxSize` if too slow
- **Profiling**: Use `traceShrink := true` to debug slow shrinking

## Examples

See individual test files for examples:

- `Generators.lean`: Generator implementations (Formula, Context, TaskFrame, TaskModel)
- `../Syntax/FormulaPropertyTest.lean`: Formula transformation properties (complexity, swap_temporal, derived operators)
- `../ProofSystem/DerivationPropertyTest.lean`: Derivation structural properties (reflexivity, weakening, height)
- `../Semantics/SemanticPropertyTest.lean`: Frame and model properties (nullity, compositionality, valuation)
- `../Metalogic/SoundnessPropertyTest.lean`: Axiom validity tests (all 14 axiom schemas)

## References

- [Plausible Framework](https://github.com/leanprover-community/plausible)
- [Property Testing Guide](../../../docs/development/PROPERTY_TESTING_GUIDE.md)
- [Research Report](../../../.opencode/specs/174_property_based_testing/reports/research-001.md)

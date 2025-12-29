# Research Report: Property-Based Testing for Lean 4

**Project**: #174  
**Date**: December 24, 2025  
**Research Type**: Technology Search and Integration Strategy

---

## Research Question

What property-based testing frameworks are available for Lean 4, and how can they be integrated into the Logos project to test metalogic properties, derivation rules, and semantic properties?

---

## Sources Consulted

- **Web Research**: 5+ sources including GitHub repositories, documentation, and community resources
- **Documentation**: Plausible README, Mathlib4 docs, Lean 4 manual
- **Code Examples**: Plausible test suite, source code analysis

---

## Key Findings

### Technologies and Frameworks

**Plausible** is the primary and only mature property-based testing framework for Lean 4:

- **Repository**: https://github.com/leanprover-community/plausible
- **Status**: Active, production-ready (74 stars, 16 forks)
- **License**: Apache 2.0
- **Maintenance**: Regularly updated by Lean community

**Key Features**:
- [PASS] Tactic integration (`plausible` tactic)
- [PASS] Command interface (`#test`)
- [PASS] Automatic derivation (`deriving Arbitrary`)
- [PASS] Automatic shrinking of counterexamples
- [PASS] No external dependencies (pure Lean)
- [PASS] Configurable test parameters

**No viable alternatives found**:
- LeanCheck: No Lean 4 port exists
- Batteries/Std4: No property-based testing functionality
- Mathlib4: May use Plausible internally but doesn't provide its own framework

### Design Patterns and Best Practices

**1. Generator Patterns**

```lean
-- Automatic derivation for simple types
inductive Formula where
  | var : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  deriving Repr, Arbitrary

-- Manual instance for types with invariants
instance : SampleableExt MyType :=
  SampleableExt.mkSelfContained do
    let x ← SampleableExt.interpSample Nat
    let y ← SampleableExt.interpSample Nat
    if h : x ≤ y then
      return ⟨x, y, h⟩
    else
      return ⟨y, x, by omega⟩

-- Size-controlled recursive generation
instance : Arbitrary Formula where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then
      Gen.oneOf [pure Formula.bot, Formula.var <$> Arbitrary.arbitrary]
    else
      Gen.oneOf [
        pure Formula.bot,
        Formula.var <$> Arbitrary.arbitrary,
        Formula.imp <$> Gen.resize (size / 2) Arbitrary.arbitrary 
                    <*> Gen.resize (size / 2) Arbitrary.arbitrary,
        Formula.box <$> Gen.resize (size - 1) Arbitrary.arbitrary
      ]
```

**2. Shrinking Patterns**

```lean
-- Shrink to simpler formulas
instance : Shrinkable Formula where
  shrink
    | Formula.var _ => []
    | Formula.bot => []
    | Formula.imp p q => [p, q] ++ 
        (Shrinkable.shrink p).map (Formula.imp · q) ++
        (Shrinkable.shrink q).map (Formula.imp p ·)
    | Formula.box p => [p] ++ 
        (Shrinkable.shrink p).map Formula.box
```

**3. Property Test Patterns**

```lean
-- Basic properties
#test ∀ φ : Formula, φ = φ

-- Properties with preconditions
#test ∀ (Γ : Context) (φ ψ : Formula)
  (h1 : Derivable Γ φ) (h2 : Derivable Γ (φ ⊃ ψ)),
  Derivable Γ ψ

-- Metalogic properties
#test ∀ (Γ : Context) (φ : Formula),
  Derivable Γ φ → Valid Γ φ  -- Soundness

-- Semantic properties
#test ∀ (F : TaskFrame) (w1 w2 w3 : F.World),
  F.accessible w1 w2 → F.accessible w2 w3 → 
  F.accessible w1 w3  -- Transitivity
```

### Implementation Strategies

**Integration Steps**:

1. **Add Dependency** (lakefile.lean):
```lean
require plausible from git
  "https://github.com/leanprover-community/plausible" @ "main"
```

2. **Create Generators** for custom types:
   - Formula: Use `deriving Arbitrary` or manual instance with size control
   - Context: Automatic (List Formula)
   - TaskFrame: Manual instance with finite world generation
   - TaskModel: Combine frame generator with valuation generator

3. **Write Property Tests** for:
   - **Metalogic**: Soundness, completeness properties
   - **Derivation**: Weakening, cut, substitution
   - **Semantics**: Frame properties, truth conditions
   - **Tactics**: Proof search correctness
   - **Transformations**: NNF, CNF idempotence

4. **Configure Testing**:
```lean
#eval Plausible.Testable.check (∀ φ : Formula, φ = φ) {
  numInst := 1000,        -- Number of test cases
  maxSize := 50,          -- Maximum formula size
  numRetries := 20,       -- Retries for preconditions
  traceShrink := true,    -- Debug shrinking
  randomSeed := some 42   -- Reproducibility
}
```

5. **Integrate with CI**:
```lean
-- LogosTest/PropertyTests.lean
def runPropertyTests : IO Unit := do
  Plausible.Testable.checkIO (∀ φ : Formula, φ = φ)
  Plausible.Testable.checkIO (∀ Γ φ, Derivable Γ φ → Valid Γ φ)
  IO.println "All property tests passed!"

#eval runPropertyTests
```

---

## Relevant Resources

### Libraries/Frameworks

- **Plausible**: https://github.com/leanprover-community/plausible
  - Primary property-based testing framework
  - QuickCheck-style random testing
  - Automatic shrinking

### Documentation

- **Plausible README**: Comprehensive usage guide
- **Mathlib4 Docs**: https://leanprover-community.github.io/mathlib4_docs/Plausible.html
- **Lean 4 Manual**: https://lean-lang.org/lean4/doc/

### Articles/Tutorials

- **QuickCheck Paper**: "QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs" (Claessen & Hughes, 2000)
- **Lean Zulip**: https://leanprover.zulipchat.com/ (search "plausible")

### Code Examples

- **Plausible Test Suite**: `Test/Plausible.lean` in repository
- **Source Code**:
  - `Testable.lean`: Main testing infrastructure
  - `Sampleable.lean`: Generator type classes
  - `Arbitrary.lean`: Built-in generators
  - `Gen.lean`: Generator monad

---

## Recommendations

### Primary Recommendation: Use Plausible

**Justification**:
1. **Only mature option**: No viable alternatives exist for Lean 4
2. **Active maintenance**: Regularly updated by Lean community
3. **Good integration**: Works as both tactic and command
4. **Automatic derivation**: Minimal boilerplate for custom types
5. **No dependencies**: Pure Lean, no NPM/TypeScript required
6. **Proven track record**: Used in various Lean 4 projects

### Implementation Priority

**Phase 1: Basic Integration** (1-2 hours)
- Add Plausible dependency to lakefile.lean
- Create basic generators for Formula and Context
- Write 5-10 simple property tests
- Verify integration works

**Phase 2: Core Properties** (2-3 hours)
- Implement generators for TaskFrame and TaskModel
- Write property tests for metalogic properties (soundness)
- Write property tests for derivation rules
- Write property tests for semantic properties

**Phase 3: Advanced Testing** (3-4 hours)
- Add property tests for proof search tactics
- Test formula transformations (NNF, CNF)
- Add shrinking strategies for better counterexamples
- Configure for CI/CD integration

**Phase 4: Optimization** (1-2 hours)
- Profile slow tests
- Optimize generators for better coverage
- Add custom shrinking for complex types
- Document testing patterns

### Testing Strategy for Logos

**Metalogic Properties**:
```lean
-- Soundness: derivable → valid
#test ∀ Γ φ, Derivable Γ φ → Valid Γ φ

-- Consistency: not derivable ⊥
#test ∀ Γ, ¬Derivable Γ Formula.bot
```

**Derivation Properties**:
```lean
-- Weakening
#test ∀ Γ Δ φ, Derivable Γ φ → Γ ⊆ Δ → Derivable Δ φ

-- Cut
#test ∀ Γ φ ψ, Derivable Γ φ → Derivable (φ :: Γ) ψ → Derivable Γ ψ
```

**Semantic Properties**:
```lean
-- Reflexivity
#test ∀ (F : TaskFrame) (w : F.World), F.accessible w w

-- Transitivity
#test ∀ (F : TaskFrame) (w1 w2 w3 : F.World),
  F.accessible w1 w2 → F.accessible w2 w3 → F.accessible w1 w3
```

**Tactic Correctness**:
```lean
-- Proof search finds valid proofs
#test ∀ φ, (proofSearch φ).isSome → Derivable [] φ

-- Axiom matching is sound
#test ∀ φ, matchesAxiom φ → Derivable [] φ
```

---

## Further Research Needed

### Short-term (Next Sprint)
- None - Plausible is sufficient for current needs

### Medium-term (Next Quarter)
- Investigate coverage-guided generation for better test quality
- Explore proof synthesis from successful property tests
- Research integration with Aesop for proof search guidance

### Long-term (Future)
- Monitor Plausible development for new features
- Consider contributing generators for modal logic types to Plausible
- Explore formal verification of property test implementations

---

## Specialist Reports

- **Web Research**: Documentation/Research/property-based-testing-lean4.md
  - Comprehensive findings on Plausible framework
  - Detailed integration instructions
  - Code examples for all patterns
  - Complete API reference

---

## Appendix: Quick Reference

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
  interp : proxy → α
```

### Common Generators

```lean
Gen.choose : Nat → Nat → Gen Nat
Gen.oneOf : List (Gen α) → Gen α
Gen.listOf : Gen α → Gen (List α)
Gen.sized : (Nat → Gen α) → Gen α
Gen.resize : Nat → Gen α → Gen α
```

### Configuration

```lean
structure Configuration where
  numInst : Nat := 100
  maxSize : Nat := 100
  numRetries : Nat := 10
  traceDiscarded : Bool := false
  traceSuccesses : Bool := false
  traceShrink : Bool := false
  randomSeed : Option Nat := none
  quiet : Bool := false
```

---

## Conclusion

**Plausible** is the recommended property-based testing framework for Lean 4 and is ideal for the Logos project. It provides:

- [PASS] Easy integration via lakefile.lean
- [PASS] Automatic derivation for custom types
- [PASS] Good shrinking for minimal counterexamples
- [PASS] Active maintenance by Lean community
- [PASS] No external dependencies
- [PASS] Comprehensive documentation

**Next Steps**:
1. Add Plausible to project dependencies
2. Create generators for Formula, Context, TaskFrame
3. Write property tests for metalogic properties
4. Integrate into CI/CD pipeline
5. Use to guide development and find edge cases

**Expected Benefits**:
- Find edge cases in proof search algorithms
- Validate metalogic properties (soundness, completeness)
- Test derivation rules and tactics
- Ensure semantic properties hold
- Improve code quality and confidence

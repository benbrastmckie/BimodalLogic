# Testing Standards for Logos

This document defines testing requirements, organization, and best practices for the Logos project.

## 1. Test Organization Structure

```
Tests/
├── Unit/                          # Unit tests per module
│   ├── Syntax/
│   │   ├── FormulaTests.lean      # Formula construction tests
│   │   ├── ContextTests.lean      # Context operations tests
│   │   └── OperatorsTests.lean    # Derived operators tests
│   ├── ProofSystem/
│   │   ├── AxiomsTests.lean       # Axiom application tests
│   │   ├── RulesTests.lean        # Inference rule tests
│   │   └── DerivationTests.lean   # Derivability tests
│   ├── Semantics/
│   │   ├── TaskFrameTests.lean    # Task frame tests
│   │   ├── WorldHistoryTests.lean # World history tests
│   │   ├── TruthTests.lean        # Truth evaluation tests
│   │   └── ValidityTests.lean     # Validity tests
│   └── Automation/
│       └── TacticsTests.lean      # Custom tactic tests
├── Integration/
│   ├── SoundnessTests.lean        # End-to-end soundness tests
│   ├── CompletenessTests.lean     # Completeness tests
│   └── FullWorkflowTests.lean     # Full proof workflow tests
├── Examples/
│   ├── PerpetuityTests.lean       # P1-P6 derivation tests
│   ├── ModalTests.lean            # Modal logic examples as tests
│   └── TemporalTests.lean         # Temporal logic examples as tests
└── Metalogic/
    ├── ConsistencyTests.lean      # TM-consistency tests
    └── DecidabilityTests.lean     # Decision procedure tests
```

## 2. Test Types

### Unit Tests
Test individual functions and definitions in isolation.

```lean
-- Tests/Unit/Syntax/FormulaTests.lean
import Logos.Syntax.Formula

namespace Logos.Tests.Unit.Syntax

open Logos.Syntax

/-- Test formula complexity calculation for atoms -/
#guard (Formula.atom "p").complexity = 1

/-- Test formula complexity calculation for bot -/
#guard Formula.bot.complexity = 1

/-- Test formula complexity calculation for implication -/
#guard (Formula.imp (Formula.atom "p") (Formula.atom "q")).complexity = 3

/-- Test negation definition -/
example : neg (Formula.atom "p") = (Formula.atom "p").imp Formula.bot := rfl

/-- Test diamond definition -/
example : diamond (Formula.atom "p") = neg (Formula.box (neg (Formula.atom "p"))) := rfl

end Logos.Tests.Unit.Syntax
```

### Example-Based Tests
Test that example proofs compile and type-check.

```lean
-- Tests/Examples/PerpetuityTests.lean
import Logos

namespace Logos.Tests.Examples

open Logos.Syntax
open Logos.ProofSystem
open Logos.Theorems

/-- Test P1: □φ → always φ is derivable -/
example (φ : Formula) : ⊢ (φ.box.imp (always φ)) := perpetuity_1 φ

/-- Test P2: sometimes φ → ◇φ is derivable -/
example (φ : Formula) : ⊢ ((sometimes φ).imp (diamond φ)) := perpetuity_2 φ

/-- Test modus ponens application -/
example (P Q : Formula) : [P.imp Q, P] ⊢ Q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp

end Logos.Tests.Examples
```

### Property Tests
Test properties that should hold for all inputs.

```lean
-- Tests/Metalogic/ConsistencyTests.lean
import Logos

namespace Logos.Tests.Metalogic

open Logos.Syntax
open Logos.ProofSystem
open Logos.Semantics

/-- Axiom MT is valid (property test) -/
theorem test_modal_t_valid (φ : Formula) :
  valid (φ.box.imp φ) := modal_t_valid φ

/-- Soundness holds for empty context -/
theorem test_soundness_empty (φ : Formula) :
  ⊢ φ → ⊨ φ := valid_if_provable φ

/-- Derivability is preserved under weakening -/
theorem test_weakening (Γ Δ : Context) (φ : Formula) (h1 : Γ ⊢ φ) (h2 : Γ ⊆ Δ) :
  Δ ⊢ φ := Derivable.weakening Γ Δ φ h1 h2

end Logos.Tests.Metalogic
```

### Regression Tests
Test specific bugs that were fixed.

```lean
-- Tests/Unit/ProofSystem/RegressionTests.lean
import Logos

namespace Logos.Tests.Regression

open Logos.Syntax
open Logos.ProofSystem

/-- Regression test for issue #42: Nested modal formulas -/
example : ⊢ ((Formula.box (Formula.box (Formula.atom "p"))).imp
             (Formula.box (Formula.atom "p"))) := by
  -- Previously failed due to incorrect box handling
  apply Derivable.axiom
  apply Axiom.modal_t

end Logos.Tests.Regression
```

## 3. Test Naming Conventions

### File Naming
- Unit tests: `<Module>Tests.lean` (e.g., `FormulaTests.lean`)
- Integration tests: `<Feature>Tests.lean` (e.g., `SoundnessTests.lean`)
- Regression tests: `RegressionTests.lean` or `Issue<Number>Tests.lean`

### Test Naming
- Format: `test_<feature>_<expected_behavior>`
- Use descriptive names that explain what is being tested

```lean
-- Good names
#guard test_formula_complexity_atom
#guard test_derivable_axiom_mt
example test_soundness_modus_ponens : ...
theorem test_completeness_maximal_consistency : ...

-- Avoid
#guard test1
#guard formula_test
example my_test : ...
```

### Namespace Organization
Tests live in `Logos.Tests.<Category>.<Module>`:

```lean
namespace Logos.Tests.Unit.Syntax
namespace Logos.Tests.Integration
namespace Logos.Tests.Examples
namespace Logos.Tests.Metalogic
```

## 4. Coverage Requirements

### Overall Coverage Targets
| Category | Target |
|----------|--------|
| Overall | ≥85% |
| Metalogic/ | ≥90% |
| Automation/ | ≥80% |
| Error handling | ≥75% |

### Coverage by Module

| Module | Coverage Target | Priority |
|--------|-----------------|----------|
| `Syntax/Formula.lean` | ≥90% | High |
| `Syntax/Context.lean` | ≥85% | Medium |
| `ProofSystem/Axioms.lean` | ≥95% | Critical |
| `ProofSystem/Derivation.lean` | ≥90% | Critical |
| `Semantics/Truth.lean` | ≥90% | Critical |
| `Metalogic/Soundness.lean` | ≥95% | Critical |
| `Metalogic/Completeness.lean` | ≥90% | Critical |
| `Automation/Tactics.lean` | ≥80% | Medium |

### What to Test

**Must test:**
- All public functions
- All constructors of inductive types
- All axiom applications
- All inference rules
- Edge cases (empty contexts, atomic formulas, deeply nested formulas)

**Should test:**
- Internal helper functions
- Error conditions
- Performance-critical paths

**Optional:**
- Trivial getters/setters
- Generated code (instances)

## 5. CI/CD Integration

### GitHub Actions Workflow
Tests run automatically on every push and PR:

```yaml
# .github/workflows/ci.yml (test section)
- name: Run tests
  run: lake test

- name: Run linter
  run: lake lint
```

### Test Execution
```bash
# Run all tests
lake test

# Run specific test file (if supported)
lake env lean Tests/Unit/Syntax/FormulaTests.lean

# Run with verbose output
lake test -- --verbose
```

### Pre-commit Checklist
Before committing:
1. Run `lake build` - ensure compilation succeeds
2. Run `lake test` - ensure all tests pass
3. Run `lake lint` - ensure no lint warnings
4. Review test coverage for changed modules

## 6. TDD Workflow

### RED-GREEN-REFACTOR Cycle

**1. RED: Write a failing test**
```lean
-- Tests/Unit/ProofSystem/NewFeatureTests.lean
/-- Test new axiom X application -/
example (φ : Formula) : ⊢ (φ.new_operator.imp φ) := by
  apply Derivable.axiom
  apply Axiom.new_axiom_x  -- Doesn't exist yet, test fails
```

**2. GREEN: Implement minimal code to pass**
```lean
-- Logos/ProofSystem/Axioms.lean
inductive Axiom : Formula → Prop
  | ...
  | new_axiom_x (φ : Formula) : Axiom (φ.new_operator.imp φ)
```

**3. REFACTOR: Improve code quality**
```lean
-- Clean up, add docstrings, optimize if needed
/-- Axiom X: new_operator φ → φ

This axiom expresses that the new operator preserves truth.
-/
| new_axiom_x (φ : Formula) : Axiom (φ.new_operator.imp φ)
```

### TDD Best Practices
1. Write the test first, before implementation
2. Write the simplest test that could possibly fail
3. Write only enough code to make the test pass
4. Refactor after the test passes
5. Keep tests fast (< 1 second per test ideally)

## 7. Test Patterns and Examples

### Testing Inductive Types

```lean
-- Test all constructors
#guard (Formula.atom "p").complexity = 1
#guard Formula.bot.complexity = 1
#guard (Formula.imp (Formula.atom "p") (Formula.atom "q")).complexity = 3
#guard (Formula.box (Formula.atom "p")).complexity = 2
#guard (Formula.past (Formula.atom "p")).complexity = 2
#guard (Formula.future (Formula.atom "p")).complexity = 2
```

### Testing Functions

```lean
-- Test normal cases
#guard neg (Formula.atom "p") = (Formula.atom "p").imp Formula.bot

-- Test edge cases
#guard neg Formula.bot = Formula.bot.imp Formula.bot

-- Test composition
#guard neg (neg (Formula.atom "p")) =
  ((Formula.atom "p").imp Formula.bot).imp Formula.bot
```

### Testing Theorems

```lean
-- Test that theorem type-checks
example (φ : Formula) : ⊢ (φ.box.imp φ) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Test that theorem applies correctly
example : [Formula.box (Formula.atom "p")] ⊢ Formula.atom "p" := by
  apply Derivable.modus_ponens
  · apply Derivable.axiom
    apply Axiom.modal_t
  · apply Derivable.assumption
    simp
```

### Testing Tactics

```lean
-- Test custom tactic succeeds
example (P : Formula) : ⊢ (P.box.imp P) := by
  modal_auto  -- Custom tactic

-- Test custom tactic handles edge cases
example (P Q : Formula) : ⊢ ((P.box.and Q.box).imp (P.and Q).box) := by
  modal_auto  -- Should handle conjunction of boxes
```

## 8. Common Testing Mistakes

### Avoid These Patterns

```lean
-- Bad: Test depends on unproven theorems
example : ... := by
  exact some_unproven_theorem  -- Uses sorry internally

-- Bad: Test is trivially true
#guard true = true

-- Bad: Test doesn't test the actual functionality
example (φ : Formula) : φ = φ := rfl  -- Tests equality, not formula behavior

-- Bad: Non-deterministic test
#guard random_function () = expected_value  -- May fail randomly

-- Bad: Test with magic numbers
#guard some_function 42 = 1764  -- Why 42? Why 1764?
```

### Better Alternatives

```lean
-- Good: Test actual behavior
#guard (Formula.atom "p").complexity = 1

-- Good: Document expected values
-- Complexity of (p → q) should be complexity(p) + complexity(q) + 1 = 1 + 1 + 1 = 3
#guard (Formula.imp (Formula.atom "p") (Formula.atom "q")).complexity = 3

-- Good: Test edge cases explicitly
#guard Formula.bot.complexity = 1  -- Simplest formula

-- Good: Property-based approach
theorem formula_complexity_positive (φ : Formula) : φ.complexity > 0 := by
  induction φ <;> simp [Formula.complexity] <;> omega
```

## 9. Test Documentation

### Documenting Tests

```lean
/-!
# Formula Tests

Unit tests for the Formula type defined in Logos.Syntax.Formula.

## Test Categories

1. **Constructor tests**: Test each Formula constructor
2. **Derived operator tests**: Test neg, diamond, etc.
3. **Complexity tests**: Test complexity calculation
4. **Equality tests**: Test decidable equality

## Coverage

These tests achieve 95% coverage of Formula.lean.
-/

namespace Logos.Tests.Unit.Syntax

/-- Test that atom complexity is 1.
Atoms are the simplest formulas with no subformulas. -/
#guard (Formula.atom "p").complexity = 1
```

### Test Comments
- Explain what the test verifies
- Note any edge cases being tested
- Reference issue numbers for regression tests

## References

- [LEAN Style Guide](LEAN_STYLE_GUIDE.md)
- [Module Organization](MODULE_ORGANIZATION.md)
- [Quality Metrics](QUALITY_METRICS.md)

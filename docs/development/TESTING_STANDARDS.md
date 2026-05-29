# Testing Standards for ProofChecker

This document defines testing requirements, organization, and best practices for the ProofChecker project.

## 1. Test Organization Structure

```
Tests/
└── BimodalTest/               # Test suite mirroring Theories/Bimodal/ structure
    ├── BimodalTest.lean       # Test root
    ├── Syntax/
    │   ├── FormulaTest.lean   # Formula construction tests
    │   └── ContextTest.lean   # Context operations tests
    ├── ProofSystem/
    │   ├── AxiomsTest.lean    # Axiom application tests
    │   └── DerivationTest.lean # Derivability tests
    ├── Semantics/
    │   ├── TaskFrameTest.lean  # Task frame tests
    │   └── TruthTest.lean      # Truth evaluation tests
    ├── Metalogic/
    │   ├── SoundnessTest.lean  # Soundness property tests
    │   └── CompletenessTest.lean # Completeness tests
    ├── Theorems/
    │   ├── PerpetuityTest.lean # P1-P6 derivation tests
    │   └── PropositionalTest.lean # Propositional theorem tests
    └── Automation/
        └── TacticsTest.lean    # Custom tactic tests
```

## 2. Test Types

### Unit Tests

Test individual functions and definitions in isolation.

```lean
-- Tests/BimodalTest/Syntax/FormulaTest.lean
import Bimodal.Syntax.Formula

namespace Bimodal.Tests.Syntax

open Bimodal.Syntax

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

end Bimodal.Tests.Syntax
```

### Example-Based Tests

Test that example proofs compile and type-check.

```lean
-- Tests/BimodalTest/Theorems/PerpetuityTest.lean
import Bimodal

namespace Bimodal.Tests.Theorems

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems

/-- Test P1: □φ → always φ is derivable -/
example (φ : Formula) : ⊢ (φ.box.imp (always φ)) := perpetuity_1 φ

/-- Test P2: sometimes φ → ◇φ is derivable -/
example (φ : Formula) : ⊢ ((sometimes φ).imp (diamond φ)) := perpetuity_2 φ

/-- Test modus ponens application -/
example (P Q : Formula) : [P.imp Q, P] ⊢ Q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp

end Bimodal.Tests.Theorems
```

### Property Tests

Test properties that should hold for all inputs.

```lean
-- Tests/BimodalTest/Metalogic/SoundnessTest.lean
import Bimodal

namespace Bimodal.Tests.Metalogic

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/-- Axiom MT is valid (property test) -/
theorem test_modal_t_valid (φ : Formula) :
  valid (φ.box.imp φ) := modal_t_valid φ

/-- Soundness holds for empty context -/
theorem test_soundness_empty (φ : Formula) :
  ⊢ φ → ⊨ φ := valid_if_provable φ

/-- Derivability is preserved under weakening -/
theorem test_weakening (Γ Δ : Context) (φ : Formula) (h1 : Γ ⊢ φ) (h2 : Γ ⊆ Δ) :
  Δ ⊢ φ := Derivable.weakening Γ Δ φ h1 h2

end Bimodal.Tests.Metalogic
```

### Regression Tests

Test specific bugs that were fixed.

```lean
-- Tests/BimodalTest/ProofSystem/RegressionTest.lean
import Bimodal

namespace Bimodal.Tests.Regression

open Bimodal.Syntax
open Bimodal.ProofSystem

/-- Regression test: Nested modal formulas -/
example : ⊢ ((Formula.box (Formula.box (Formula.atom "p"))).imp
             (Formula.box (Formula.atom "p"))) := by
  apply Derivable.axiom
  apply Axiom.modal_t

end Bimodal.Tests.Regression
```

## 3. Test Naming Conventions

### File Naming

- Test files: `<Module>Test.lean` (e.g., `FormulaTest.lean`)
- Regression tests: `RegressionTest.lean` or included in the relevant module test file

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
```

### Namespace Organization

Tests live in `Bimodal.Tests.<Category>.<Module>`:

```lean
namespace Bimodal.Tests.Syntax
namespace Bimodal.Tests.Metalogic
namespace Bimodal.Tests.Theorems
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
lake env lean Tests/BimodalTest/Syntax/FormulaTest.lean

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
-- Tests/BimodalTest/ProofSystem/NewFeatureTest.lean
/-- Test new axiom X application -/
example (φ : Formula) : ⊢ (φ.new_operator.imp φ) := by
  apply Derivable.axiom
  apply Axiom.new_axiom_x  -- Doesn't exist yet, test fails
```

**2. GREEN: Implement minimal code to pass**

```lean
-- Theories/Bimodal/ProofSystem/Axioms.lean
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
#guard (Formula.all_past (Formula.atom "p")).complexity = 2
#guard (Formula.all_future (Formula.atom "p")).complexity = 2
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

Unit tests for the Formula type defined in Bimodal.Syntax.Formula.

## Test Categories

1. **Constructor tests**: Test each Formula constructor
2. **Derived operator tests**: Test neg, diamond, etc.
3. **Complexity tests**: Test complexity calculation
4. **Equality tests**: Test decidable equality

## Coverage

These tests achieve 95% coverage of Formula.lean.
-/

namespace Bimodal.Tests.Syntax

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

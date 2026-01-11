# Module Organization for Logos

This document specifies the directory structure, namespace conventions, and module organization for the Logos project.

## 1. Directory Structure

```
Logos/
├── Logos.lean                  # Library root (re-exports Core)
├── Logos/                      # Main source directory
│   ├── Core/                   # Layer 0 (TM bimodal logic)
│   │   ├── Syntax/             # Context.lean, Formula.lean
│   │   ├── ProofSystem/        # Axioms.lean, Derivation.lean
│   │   ├── Semantics/          # TaskFrame.lean, WorldHistory.lean, TaskModel.lean, Truth.lean, Validity.lean
│   │   ├── Metalogic/          # Soundness.lean, Completeness.lean, DeductionTheorem.lean
│   │   ├── Theorems/           # Combinators.lean, GeneralizedNecessitation.lean, ModalS4.lean, ModalS5.lean, Perpetuity.lean, Propositional.lean, Perpetuity/*
│   │   ├── Automation/         # Tactics.lean, ProofSearch.lean, AesopRules.lean, README.md
│   │   ├── Automation.lean
│   │   ├── Core.lean
│   │   ├── Metalogic.lean
│   │   ├── ProofSystem.lean
│   │   ├── Semantics.lean
│   │   ├── Syntax.lean
│   │   └── Theorems.lean
│   ├── Epistemic/              # Epistemic.lean, README.md (planned extensions)
│   ├── Explanatory/            # Explanatory.lean, README.md (planned extensions)
│   ├── Normative/              # Normative.lean, README.md (planned extensions)
│   ├── Lint/                   # EnvLinters.lean
│   ├── Automation.lean         # Aggregates Core.Automation
│   ├── Core.lean               # Aggregates Core layer
│   ├── Epistemic.lean
│   ├── Explanatory.lean
│   ├── Metalogic.lean          # (alias aggregation)
│   ├── Normative.lean
│   ├── ProofSystem.lean
│   ├── README.md
│   ├── Semantics.lean
│   ├── Syntax.lean
│   └── Theorems.lean
├── Archive/                    # Pedagogical examples (ModalProofs.lean, TemporalProofs.lean, BimodalProofs.lean, etc.)
├── LogosTest/                  # Test suite mirroring Logos/Core structure
│   ├── Core/Automation/        # Tactics tests, ProofSearch tests
│   ├── Core/Metalogic/         # SoundnessTest, CompletenessTest, DeductionTheoremTest
│   ├── Core/ProofSystem/       # AxiomsTest, DerivationTest
│   ├── Core/Semantics/         # TaskFrameTest, TruthTest, etc.
│   ├── Core/Syntax/            # ContextTest, FormulaTest
│   ├── Core/Theorems/          # ModalS4Test, ModalS5Test, PerpetuityTest, PropositionalTest
│   ├── Integration/            # End-to-end integration tests
│   ├── Integration.lean
│   └── LogosTest.lean
├── scripts/                    # Lint and utility scripts (LintAll.lean, LintStyle.lean, RunEnvLinters.lean)
└── docs/              # Documentation (UserGuide/, Development/, ProjectInfo/, Reference/, Research/)
```

## 2. Namespace Conventions

### Root Namespace
All Logos code lives under the `Logos` namespace:

```lean
namespace Logos

-- All definitions here

end Logos
```

### Hierarchical Namespaces
Namespaces mirror directory structure (Core layer under `Logos.Core`):

| Directory | Namespace |
|-----------|-----------|
| `Logos/Core/Syntax/` | `Logos.Core.Syntax` |
| `Logos/Core/ProofSystem/` | `Logos.Core.ProofSystem` |
| `Logos/Core/Semantics/` | `Logos.Core.Semantics` |
| `Logos/Core/Metalogic/` | `Logos.Core.Metalogic` |
| `Logos/Core/Theorems/` | `Logos.Core.Theorems` |
| `Logos/Core/Automation/` | `Logos.Core.Automation` |
| `Logos/Epistemic/` | `Logos.Epistemic` |
| `Logos/Explanatory/` | `Logos.Explanatory` |
| `Logos/Normative/` | `Logos.Normative` |
| `Logos/Lint/` | `Logos.Lint` |

### Nested Namespaces
Use nested namespaces for logical grouping within a file:

```lean
-- In Logos/Syntax/Formula.lean
namespace Logos.Syntax

inductive Formula : Type
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula
  | future : Formula → Formula

namespace Formula

/-- Complexity measure for formulas -/
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => φ.complexity + ψ.complexity + 1
  | box φ => φ.complexity + 1
  | past φ => φ.complexity + 1
  | future φ => φ.complexity + 1

end Formula

end Logos.Syntax
```

## 3. Module Dependencies

### Layered Architecture
Dependencies flow in one direction to prevent circular imports:

```
Layer 4: Automation (depends on all below)
    ↑
Layer 3: Metalogic (depends on ProofSystem, Semantics)
    ↑
Layer 2: Semantics, Theorems (depend on Syntax, ProofSystem)
    ↑
Layer 1: ProofSystem (depends on Syntax)
    ↑
Layer 0: Syntax (no internal dependencies)
```

### Dependency Rules

1. **Syntax** has no internal dependencies.
2. **ProofSystem** depends only on Syntax.
3. **Semantics** depends on Syntax and ProofSystem.
4. **Theorems** depends on Syntax and ProofSystem (and may use Semantics for transport lemmas where needed).
5. **Metalogic** depends on Syntax, ProofSystem, Semantics, and Theorems infrastructure used in proofs.
6. **Automation** (tactics, proof search) may depend on any Core module.
7. **Extension layers** (Epistemic, Explanatory, Normative) depend on Core and should not be imported by Core.

### Import Guidelines

```lean
-- Logos/ProofSystem/Derivation.lean
-- Good: Only imports from Syntax (lower layer)
import Logos.Syntax.Formula
import Logos.Syntax.Context
import Logos.ProofSystem.Axioms
import Logos.ProofSystem.Rules

-- Bad: Would create circular dependency
-- import Logos.Semantics.Truth  -- Semantics depends on ProofSystem!
```

### Detecting Circular Dependencies
Lake will report circular dependencies at build time. If you encounter them:
1. Identify the cycle by examining import chains
2. Extract shared definitions to a lower-level module
3. Consider whether the dependency direction should be reversed

## 4. File Structure Template

Every LEAN file should follow this structure:

```lean
/-!
# Module Title

Brief description of what this module provides.

## Main Definitions

* `Definition1` - What it represents
* `Definition2` - What it represents

## Main Theorems

* `theorem1` - What it proves
* `theorem2` - What it proves

## Implementation Notes

Any important implementation details or design decisions.

## References

* Reference 1
* Reference 2
-/

-- 1. Imports (ordered by: standard library, mathlib, project)
import Init.Data.List
import Logos.Syntax.Formula

-- 2. Namespace opening
namespace Logos.ModuleName

-- 3. Local notation (if needed)
local notation "⊥" => Formula.bot

-- 4. Type definitions
/-- Docstring -/
structure MyStructure where
  field1 : Type
  field2 : Type

-- 5. Function definitions
/-- Docstring -/
def myFunction (x : Nat) : Nat := x + 1

-- 6. Theorems and lemmas
/-- Docstring -/
theorem myTheorem : 1 + 1 = 2 := rfl

-- 7. Instances
instance : Inhabited MyStructure where
  default := { field1 := Unit, field2 := Unit }

-- 8. Namespace closing
end Logos.ModuleName
```

## 5. Library Root File

The `Logos.lean` file re-exports the Core layer via `Logos.Core`, which aggregates the public API:

```lean
/-!
# Logos

LEAN 4 implementation of an axiomatic proof system for the bimodal logic TM
with task semantics.

## Core Modules (via Logos.Core)

### Syntax
* `Logos.Core.Syntax.Formula`
* `Logos.Core.Syntax.Context`

### Proof System
* `Logos.Core.ProofSystem.Axioms`
* `Logos.Core.ProofSystem.Derivation`

### Semantics
* `Logos.Core.Semantics.TaskFrame`
* `Logos.Core.Semantics.WorldHistory`
* `Logos.Core.Semantics.TaskModel`
* `Logos.Core.Semantics.Truth`
* `Logos.Core.Semantics.Validity`

### Metalogic
* `Logos.Core.Metalogic.Soundness`
* `Logos.Core.Metalogic.Completeness`
* `Logos.Core.Metalogic.DeductionTheorem`

### Theorems
* `Logos.Core.Theorems.Perpetuity`
* `Logos.Core.Theorems.ModalS4`
* `Logos.Core.Theorems.ModalS5`
* `Logos.Core.Theorems.GeneralizedNecessitation`
* `Logos.Core.Theorems.Combinators`
* `Logos.Core.Theorems.Propositional`

### Automation
* `Logos.Core.Automation.Tactics`
* `Logos.Core.Automation.ProofSearch`
-/

-- Library root (aggregated via Core)
import Logos.Core
```

## 6. Public API vs Internal Implementation

### Public API
Definitions that users should use directly:

- Marked with docstrings
- Re-exported from `Logos.lean`
- Stable across versions

```lean
/-- The formula type for TM logic. -/
inductive Formula : Type
  ...

/-- Check if a formula is valid. -/
def valid (φ : Formula) : Prop := ...

/-- The soundness theorem. -/
theorem soundness : Γ ⊢ φ → Γ ⊨ φ := ...
```

### Internal Implementation
Helper functions and intermediate definitions:

- May be placed in `Internal` sub-namespace
- Not re-exported from root
- May change between versions

```lean
namespace Logos.Semantics.Internal

/-- Internal helper for canonical model construction. -/
def extend_consistent_set (Γ : Context) : Context := ...

end Logos.Semantics.Internal
```

### Access Control Pattern

```lean
-- In Logos/Semantics/Canonical.lean
namespace Logos.Semantics

namespace Internal

-- Internal helpers
def helper1 := ...
def helper2 := ...

end Internal

-- Public API uses internal helpers
/-- Build canonical model for completeness proof. -/
def canonical_model : TaskModel canonical_frame :=
  { valuation := Internal.helper1 ... }

end Logos.Semantics
```

## 7. Module Size Guidelines

### Recommended Limits
- **Lines per file**: ≤1000 lines
- **Definitions per file**: ≤30 major definitions
- **Nesting depth**: ≤4 namespace levels

### When to Split a Module
Split a module when:
1. It exceeds 1000 lines
2. It has multiple independent logical sections
3. Different sections have different dependency requirements
4. Testing becomes difficult

### How to Split
1. Identify logical boundaries
2. Create new file for extracted content
3. Update imports in both files
4. Update re-exports in library root

## 8. Examples Module Organization

Pedagogical examples live in `Archive/` (not under `Examples/`). These files use only proven components and mirror Core namespaces:

- `Archive/ModalProofs.lean` – S5 modal logic examples
- `Archive/TemporalProofs.lean` – Temporal reasoning examples
- `Archive/BimodalProofs.lean` – Combined modal-temporal examples
- Additional archived samples as maintained in `Archive/`

All examples import `Logos` (or targeted Core modules) and avoid unproven axioms.

## 9. Test Module Organization

See [TESTING_STANDARDS.md](TESTING_STANDARDS.md) for detailed test organization.

Summary:
- `LogosTest/Core/` mirrors `Logos/Core/` (Automation, Metalogic, ProofSystem, Semantics, Syntax, Theorems)
- `LogosTest/Integration/` contains cross-module and end-to-end tests
- Test files are named `<Module>Test.lean` and collected via `LogosTest.lean`/`Integration.lean`

## References

- [LEAN Style Guide](LEAN_STYLE_GUIDE.md)
- [Testing Standards](TESTING_STANDARDS.md)
- [Architecture Guide](../user-guide/ARCHITECTURE.md)

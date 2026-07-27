# Module Organization for ProofChecker

This document specifies the directory structure, namespace conventions, and module organization for the ProofChecker project (BimodalLogic repository). The primary library is the `Bimodal` theory, residing under `FormalSystem/`.

## 1. Directory Structure

```
BimodalLogic/
├── lakefile.toml               # Lake build configuration (package name: Logos)
├── FormalSystem/
│   └── Bimodal/                # Main library source
│       ├── FormalSystem.lean        # Library root (re-exports all sub-modules)
│       ├── Syntax.lean         # Aggregates Syntax/
│       ├── ProofSystem.lean    # Aggregates ProofSystem/
│       ├── Semantics.lean      # Aggregates Semantics/
│       ├── Metalogic.lean      # Aggregates Metalogic/
│       ├── Theorems.lean       # Aggregates Theorems/
│       ├── Automation.lean     # Aggregates Automation/
│       ├── Syntax/             # Formula types, atoms, contexts
│       ├── ProofSystem/        # Axioms, derivation trees, inference rules
│       ├── Semantics/          # Task frame semantics, truth evaluation
│       ├── Metalogic/          # Soundness, completeness, decidability
│       ├── Theorems/           # Derived theorems (perpetuity, combinators, propositional)
│       ├── Automation/         # Proof tactics and search
│       ├── Examples/           # Pedagogical examples
│       ├── FrameConditions/    # Frame condition characterizations
│       ├── Boneyard/           # Archived/experimental work
│       └── docs/               # Theory-specific documentation
├── Tests/
│   └── BimodalTest/            # Test suite mirroring FormalSystem/ structure
│       ├── BimodalTest.lean    # Test root
│       ├── Syntax/             # Syntax tests
│       ├── ProofSystem/        # Proof system tests
│       ├── Semantics/          # Semantic tests
│       ├── Metalogic/          # Metalogic tests
│       ├── Theorems/           # Theorem tests
│       └── Automation/         # Automation tests
└── docs/                       # Project-level documentation
```

## 2. Namespace Conventions

### Root Namespace

All library code lives under the `Bimodal` namespace:

```lean
namespace Bimodal

-- All definitions here

end Bimodal
```

### Hierarchical Namespaces

Namespaces mirror directory structure:

| Directory | Namespace |
|-----------|-----------|
| `FormalSystem/Syntax/` | `FormalSystem.Syntax` |
| `FormalSystem/ProofSystem/` | `FormalSystem.ProofSystem` |
| `FormalSystem/Semantics/` | `FormalSystem.Semantics` |
| `FormalSystem/Metalogic/` | `FormalSystem.Metalogic` |
| `FormalSystem/Theorems/` | `FormalSystem.Theorems` |
| `FormalSystem/Automation/` | `FormalSystem.Automation` |

### Nested Namespaces

Use nested namespaces for logical grouping within a file:

```lean
-- In FormalSystem/Syntax/Formula.lean
namespace FormalSystem.Syntax

inductive Formula : Type
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | allPast : Formula → Formula
  | allFuture : Formula → Formula

namespace Formula

/-- Complexity measure for formulas -/
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => φ.complexity + ψ.complexity + 1
  | box φ => φ.complexity + 1
  | allPast φ => φ.complexity + 1
  | allFuture φ => φ.complexity + 1

end Formula

end FormalSystem.Syntax
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
6. **Automation** (tactics, proof search) may depend on any module.

### Import Guidelines

```lean
-- FormalSystem/ProofSystem/Derivation.lean
-- Good: Only imports from Syntax (lower layer)
import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context
import FormalSystem.ProofSystem.Axioms
import FormalSystem.ProofSystem.Derivation

-- Bad: Would create circular dependency
-- import FormalSystem.Semantics.Truth  -- Semantics depends on ProofSystem!
```

### Detecting Circular Dependencies

Lake will report circular dependencies at build time. If you encounter them:
1. Identify the cycle by examining import chains
2. Extract shared definitions to a lower-level module
3. Consider whether the dependency direction should be reversed

## 4. File Structure Template

Every Lean file should follow this structure:

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
import FormalSystem.Syntax.Formula

-- 2. Namespace opening
namespace Bimodal.«ModuleName»

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
end Bimodal.«ModuleName»
```

## 5. Library Root File

The `FormalSystem.lean` file aggregates all sub-modules:

```lean
/-!
# Bimodal

Lean 4 formalization of bimodal logic TM (Tense and Modality), combining S5 modal
logic with linear temporal logic. Proven sound and complete.

## Core Modules

### Syntax
* `FormalSystem.Syntax.Formula`
* `FormalSystem.Syntax.Context`

### Proof System
* `FormalSystem.ProofSystem.Axioms`
* `FormalSystem.ProofSystem.Derivation`

### Semantics
* `FormalSystem.Semantics.TaskFrame`
* `FormalSystem.Semantics.WorldHistory`
* `FormalSystem.Semantics.TaskModel`
* `FormalSystem.Semantics.Truth`
* `FormalSystem.Semantics.Validity`

### Metalogic
* `FormalSystem.Metalogic.Soundness`
* `FormalSystem.Metalogic.BXCanonical`
* `FormalSystem.Metalogic.WeakCanonical`
* `FormalSystem.Metalogic.Algebraic`
* `FormalSystem.Metalogic.Core.DeductionTheorem`

### Theorems
* `FormalSystem.Theorems.Perpetuity`
* `FormalSystem.Theorems.ModalS4`
* `FormalSystem.Theorems.ModalS5`
* `FormalSystem.Theorems.GeneralizedNecessitation`
* `FormalSystem.Theorems.Combinators`
* `FormalSystem.Theorems.Propositional`

### Automation
* `FormalSystem.Automation.Tactics`
* `FormalSystem.Automation.ProofSearch`
-/

import FormalSystem.Syntax
import FormalSystem.ProofSystem
import FormalSystem.Semantics
import FormalSystem.Metalogic
import FormalSystem.Theorems
import FormalSystem.Automation
```

## 6. Public API vs Internal Implementation

### Public API

Definitions that users should use directly:

- Marked with docstrings
- Re-exported from `FormalSystem.lean`
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
namespace FormalSystem.Semantics.«Internal»

/-- Internal helper for canonical model construction. -/
def extend_consistent_set (Γ : Context) : Context := ...

end FormalSystem.Semantics.«Internal»
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

Pedagogical examples live in `FormalSystem/Examples/`. These files use only proven
components and mirror the core structure:

- `Examples/ModalProofs.lean` - S5 modal logic examples
- `Examples/TemporalProofs.lean` - Temporal reasoning examples
- `Examples/BimodalProofs.lean` - Combined modal-temporal examples

All examples import `Bimodal` (or targeted sub-modules) and avoid unproven axioms.

## 9. Test Module Organization

See [TESTING_STANDARDS.md](TESTING_STANDARDS.md) for detailed test organization.

Summary:
- `Tests/BimodalTest/` mirrors `FormalSystem/` (Syntax, ProofSystem, Semantics, Metalogic, Theorems, Automation)
- Test files are named `<Module>Test.lean` and collected via `BimodalTest.lean`

## References

- [LEAN Style Guide](LEAN_STYLE_GUIDE.md)
- [Testing Standards](TESTING_STANDARDS.md)

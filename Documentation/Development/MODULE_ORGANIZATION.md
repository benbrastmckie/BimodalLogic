# Module Organization for Logos

This document specifies the directory structure, namespace conventions, and module organization for the Logos project.

## 1. Directory Structure

```
Logos/
├── Logos.lean              # Library root (re-exports all public modules)
├── Logos/                  # Main source directory
│   ├── Syntax/                    # Formula types, parsing, DSL
│   │   ├── Formula.lean           # Core formula inductive type
│   │   ├── Context.lean           # Proof context (premise lists)
│   │   ├── Operators.lean         # Derived operators
│   │   └── DSL.lean               # Domain-specific syntax macros
│   ├── ProofSystem/               # Axioms and inference rules
│   │   ├── Axioms.lean            # TM axiom schemata
│   │   ├── Rules.lean             # Inference rules (MP, MK, TK, TD)
│   │   └── Derivation.lean        # Derivability relation
│   ├── Semantics/                 # Task frame semantics
│   │   ├── TaskFrame.lean         # Task frame structure
│   │   ├── WorldHistory.lean      # World history definition
│   │   ├── TaskModel.lean         # Model with valuation
│   │   ├── Truth.lean             # Truth evaluation
│   │   ├── Validity.lean          # Validity and consequence
│   │   └── Canonical.lean         # Canonical model construction
│   ├── Metalogic/                 # Soundness and completeness
│   │   ├── Soundness.lean         # Soundness theorem
│   │   ├── Completeness.lean      # Completeness theorem
│   │   ├── Decidability.lean      # Decision procedures
│   │   └── Interpolation.lean     # Craig interpolation
│   ├── Theorems/                  # Key theorems
│   │   ├── Perpetuity.lean        # P1-P6 perpetuity principles
│   │   └── Basic.lean             # Basic derived theorems
│   └── Automation/                # Proof automation
│       ├── Tactics.lean           # Custom tactics
│       ├── ProofSearch.lean       # Automated proof search
│       └── Templates.lean         # Proof templates
├── Examples/                      # Usage examples
│   ├── ModalProofs.lean           # S5 modal logic examples
│   ├── TemporalProofs.lean        # Temporal reasoning examples
│   └── BimodalProofs.lean         # Combined modal-temporal examples
├── Tests/                         # Test suite
│   ├── Unit/                      # Unit tests
│   │   ├── Syntax/                # Formula tests
│   │   ├── ProofSystem/           # Proof system tests
│   │   ├── Semantics/             # Semantics tests
│   │   └── Automation/            # Automation tests
│   ├── Integration/               # Integration tests
│   │   ├── SoundnessTests.lean    # End-to-end soundness
│   │   └── CompletenessTests.lean # Completeness tests
│   └── Metalogic/                 # Property tests
│       └── ConsistencyTests.lean  # Consistency tests
└── Documentation/                 # Documentation
    ├── UserGuide/                 # User-facing documentation
    │   ├── ARCHITECTURE.md
    │   ├── TUTORIAL.md
    │   ├── EXAMPLES.md
    │   └── INTEGRATION.md
    ├── ProjectInfo/               # Project status and tactic docs
    │   ├── IMPLEMENTATION_STATUS.md
    │   ├── SORRY_REGISTRY.md
    │   └── TACTIC_REGISTRY.md
    ├── Development/               # Developer standards and workflow
    │   ├── LEAN_STYLE_GUIDE.md
    │   ├── MODULE_ORGANIZATION.md
    │   ├── TESTING_STANDARDS.md
    │   ├── QUALITY_METRICS.md
    │   ├── CONTRIBUTING.md
    │   ├── MAINTENANCE.md
    │   └── VERSIONING.md
    └── Reference/                 # Reference materials
        ├── OPERATORS.md
        └── GLOSSARY.md
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
Namespaces mirror directory structure:

| Directory | Namespace |
|-----------|-----------|
| `Logos/Syntax/` | `Logos.Syntax` |
| `Logos/ProofSystem/` | `Logos.ProofSystem` |
| `Logos/Semantics/` | `Logos.Semantics` |
| `Logos/Metalogic/` | `Logos.Metalogic` |
| `Logos/Theorems/` | `Logos.Theorems` |
| `Logos/Automation/` | `Logos.Automation` |

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

1. **Syntax** has no internal dependencies
2. **ProofSystem** depends only on Syntax
3. **Semantics** depends on Syntax and ProofSystem
4. **Theorems** depends on Syntax and ProofSystem
5. **Metalogic** depends on Syntax, ProofSystem, and Semantics
6. **Automation** may depend on any module

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

The `Logos.lean` file re-exports all public modules:

```lean
/-!
# Logos

LEAN 4 implementation of an axiomatic proof system for the bimodal logic TM
with task semantics.

## Modules

### Syntax
* `Logos.Syntax.Formula` - Formula type for TM logic
* `Logos.Syntax.Context` - Proof contexts
* `Logos.Syntax.Operators` - Derived operators
* `Logos.Syntax.DSL` - Domain-specific syntax

### Proof System
* `Logos.ProofSystem.Axioms` - TM axiom schemata
* `Logos.ProofSystem.Rules` - Inference rules
* `Logos.ProofSystem.Derivation` - Derivability relation

### Semantics
* `Logos.Semantics.TaskFrame` - Task frame structure
* `Logos.Semantics.WorldHistory` - World histories
* `Logos.Semantics.TaskModel` - Task models
* `Logos.Semantics.Truth` - Truth evaluation
* `Logos.Semantics.Validity` - Validity and consequence

### Metalogic
* `Logos.Metalogic.Soundness` - Soundness theorem
* `Logos.Metalogic.Completeness` - Completeness theorem

### Theorems
* `Logos.Theorems.Perpetuity` - Perpetuity principles P1-P6

### Automation
* `Logos.Automation.Tactics` - Custom tactics
-/

-- Re-export all public modules
import Logos.Syntax.Formula
import Logos.Syntax.Context
import Logos.Syntax.Operators
import Logos.Syntax.DSL

import Logos.ProofSystem.Axioms
import Logos.ProofSystem.Rules
import Logos.ProofSystem.Derivation

import Logos.Semantics.TaskFrame
import Logos.Semantics.WorldHistory
import Logos.Semantics.TaskModel
import Logos.Semantics.Truth
import Logos.Semantics.Validity

import Logos.Metalogic.Soundness
import Logos.Metalogic.Completeness

import Logos.Theorems.Perpetuity

import Logos.Automation.Tactics
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

The `Examples/` directory contains usage examples:

```lean
-- Examples/ModalProofs.lean
/-!
# S5 Modal Logic Examples

Examples of modal reasoning using the Logos library.
-/

import Logos

open Logos.Syntax
open Logos.ProofSystem

/-- Example: Prove □p → p using axiom MT -/
example (P : Formula) : ⊢ (P.box.imp P) := by
  apply Derivable.axiom
  apply Axiom.modal_t

/-- Example: Modus ponens application -/
example (P Q : Formula) : [P.imp Q, P] ⊢ Q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp
```

## 9. Test Module Organization

See [TESTING_STANDARDS.md](TESTING_STANDARDS.md) for detailed test organization.

Summary:
- `Tests/Unit/` mirrors `Logos/` structure
- `Tests/Integration/` for cross-module tests
- `Tests/Metalogic/` for property-based tests
- Test files named `<Module>Tests.lean`

## References

- [LEAN Style Guide](LEAN_STYLE_GUIDE.md)
- [Testing Standards](TESTING_STANDARDS.md)
- [Architecture Guide](../UserGuide/ARCHITECTURE.md)

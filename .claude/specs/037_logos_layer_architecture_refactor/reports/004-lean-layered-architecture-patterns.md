# Lean 4 Layered Architecture Patterns

**Report Date**: 2025-12-04
**Analysis Scope**: Lean 4 best practices for multi-layer library organization
**Purpose**: Inform Logos layer architecture design decisions

## Executive Summary

This report synthesizes Lean 4 namespace organization best practices, module structuring patterns, and library architecture strategies to inform the Logos layer architecture refactoring. Based on Lean 4 manual, mathlib4 patterns, and recent 2025 updates, we provide concrete recommendations for organizing the four-layer Logos system.

## 1. Lean 4 Namespace Organization Fundamentals

### 1.1 Namespace Purpose and Scope

**From Lean Manual** ([Namespaces - Lean Manual](https://lean-lang.org/lean4/doc/namespaces.html)):

"Sorting operations into namespaces organizes libraries conceptually, from a global perspective. Any given Lean file will, however, typically not use all names equally. Sections provide a means of ordering a local view of the globally-available collection of names, as well as a way to precisely control the scope of compiler options along with language extensions, instances, and attributes."

**Key Principles**:
1. **Conceptual Organization**: Namespaces group related definitions logically
2. **Global Perspective**: Namespace hierarchy visible across entire project
3. **Local Control**: Sections provide fine-grained scoping within namespaces

### 1.2 Namespace Declaration Patterns

**Basic Pattern**:
```lean
namespace Logos
  -- Definitions in Logos namespace
  def version : String := "0.1.0"
end Logos
```

**Nested Namespaces**:
```lean
namespace Logos.Core
  namespace Syntax
    inductive Formula : Type
      | atom : String → Formula
      | bot : Formula
  end Syntax
end Logos.Core
```

**Equivalent Alternative** (flattened):
```lean
namespace Logos.Core.Syntax
  inductive Formula : Type
    | atom : String → Formula
    | bot : Formula
end Logos.Core.Syntax
```

**Recommendation**: Use flattened form for deeper hierarchies (reduces indentation, clearer structure).

### 1.3 Opening Namespaces

**Pattern**:
```lean
open Logos.Core.Syntax  -- Brings Formula, etc. into scope

-- Now can use Formula directly instead of Logos.Core.Syntax.Formula
def example : Formula := Formula.atom "p"
```

**Scoped Opening**:
```lean
section Examples
  open Logos.Core.Syntax
  -- Formula available here
  def ex1 : Formula := Formula.atom "p"
end Examples

-- Formula not available here (need fully qualified name)
```

**Best Practice**: Use `open` judiciously to avoid name conflicts. Prefer explicit qualification for cross-module references.

### 1.4 Exporting Names

**From Lean Reference** ([Namespaces and Sections](https://lean-lang.org/doc/reference/latest/Namespaces-and-Sections/)):

"Exporting a name makes it available in the current namespace. Unlike a definition, this alias is completely transparent: uses are resolved directly to the original name."

**Pattern**:
```lean
namespace Logos.Core
  export Syntax (Formula)  -- Makes Formula available as Logos.Core.Formula
end Logos.Core
```

**Use Case**: Creating convenient aliases without duplication.

**Caution**: Overuse can create ambiguity. Use sparingly for commonly accessed definitions.

## 2. Multi-Layer Library Architecture Patterns

### 2.1 Mathlib4 Organizational Patterns

**Mathlib4 Structure** (simplified):
```
Mathlib/
├── Logic/           # Foundational logic
├── Data/            # Data structures
├── Algebra/         # Algebraic structures
├── Topology/        # Topological spaces
└── Analysis/        # Analysis
```

**Pattern Observed**:
1. **Conceptual Grouping**: Major mathematical domains as top-level namespaces
2. **Hierarchical Depth**: 2-4 levels typical (Mathlib.Algebra.Group.Defs)
3. **Aggregator Files**: Each directory has root file re-exporting submodules
4. **Dot Imports**: Enable selective importing (import Mathlib.Algebra.Group)

**Relevance to Logos**: Similar domain-based organization applies to logic layers.

### 2.2 Layer-as-Namespace Pattern

**Recommended Structure for Logos**:
```
Logos/
├── Core/            # Layer 0 (current Logos)
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Metalogic/
│   ├── Theorems/
│   └── Automation/
├── Explanatory/     # Layer 1 (future)
│   ├── Syntax/
│   ├── ProofSystem/
│   └── Semantics/
├── Epistemic/       # Layer 2 (future)
│   └── ...
└── Normative/       # Layer 3 (future)
    └── ...
```

**Namespace Hierarchy**:
```lean
Logos                          -- Root namespace
├── Logos.Core                 -- Layer 0
│   ├── Logos.Core.Syntax
│   ├── Logos.Core.ProofSystem
│   ├── Logos.Core.Semantics
│   ├── Logos.Core.Metalogic
│   ├── Logos.Core.Theorems
│   └── Logos.Core.Automation
├── Logos.Explanatory          -- Layer 1
│   ├── Logos.Explanatory.Syntax
│   ├── Logos.Explanatory.ProofSystem
│   └── Logos.Explanatory.Semantics
├── Logos.Epistemic            -- Layer 2
└── Logos.Normative            -- Layer 3
```

### 2.3 Aggregator File Pattern

**Purpose**: Convenient import of entire module or layer.

**Pattern**:
```lean
-- Logos/Core.lean (aggregates all Layer 0 modules)
import Logos.Core.Syntax
import Logos.Core.ProofSystem
import Logos.Core.Semantics
import Logos.Core.Metalogic
import Logos.Core.Theorems
import Logos.Core.Automation

namespace Logos.Core
  -- Optional: export commonly used names
  export Syntax (Formula)
  export Semantics (TaskFrame TaskModel WorldHistory truth_at)
end Logos.Core
```

**Usage**:
```lean
import Logos.Core  -- Imports all Layer 0 modules at once
open Logos.Core

-- Now have access to all Layer 0 definitions
def example : Formula := Formula.atom "p"
```

**Recommendation**: Create aggregator files for:
1. Each layer (Logos.Core, Logos.Explanatory, etc.)
2. Each major module (Logos.Core.Syntax, Logos.Core.Semantics, etc.)
3. Root level (Logos.lean imports all layers)

### 2.4 Cross-Layer Import Patterns

**Scenario**: Layer 1 (Explanatory) extends Layer 0 (Core)

**Pattern**:
```lean
-- Logos/Explanatory/Syntax/Formula.lean
import Logos.Core.Syntax.Formula

namespace Logos.Explanatory.Syntax

-- Extend Core formula with explanatory operators
inductive ExplanatoryFormula : Type
  | core : Logos.Core.Syntax.Formula → ExplanatoryFormula
  | boxright : ExplanatoryFormula → ExplanatoryFormula → ExplanatoryFormula
  | ground : ExplanatoryFormula → ExplanatoryFormula → ExplanatoryFormula

-- Embedding from Core to Explanatory
def embed : Logos.Core.Syntax.Formula → ExplanatoryFormula :=
  ExplanatoryFormula.core

end Logos.Explanatory.Syntax
```

**Key Points**:
1. Import base layer explicitly
2. Use explicit namespace qualification for clarity
3. Define embedding/translation functions between layers
4. Keep layer dependencies unidirectional (higher layers import lower, not vice versa)

### 2.5 Shared Utilities Pattern

**Scenario**: Common utilities used across all layers

**Option 1: Common Namespace**
```
Logos/
├── Common/          # Shared utilities
│   ├── Types.lean
│   └── Tactics.lean
├── Core/
├── Explanatory/
└── ...
```

**Namespace**: `Logos.Common`

**Usage**:
```lean
import Logos.Common.Types
import Logos.Core.Syntax

namespace Logos.Core.Syntax
  open Logos.Common.Types
  -- Use common type definitions
end Logos.Core.Syntax
```

**Option 2: No Common Namespace** (Preferred)

Keep utilities in Core layer, import from there:
```lean
import Logos.Core.Common.Types
```

**Recommendation**: Avoid premature abstraction. Start without Common/ namespace. Extract shared utilities only when actual duplication occurs across layers.

## 3. Module Organization Best Practices

### 3.1 File-to-Module Correspondence

**Lean Convention**: One namespace per file (generally)

**Pattern**:
```
Logos/Core/Syntax/Formula.lean  ↔  namespace Logos.Core.Syntax.Formula
```

**Exception**: Aggregator files import multiple modules:
```lean
-- Logos/Core/Syntax.lean
import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context

-- No namespace declaration, just aggregates imports
```

**Alternative** (with namespace):
```lean
-- Logos/Core/Syntax.lean
import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context

namespace Logos.Core.Syntax
  -- Re-export key definitions
  export Formula (Formula)
  export Context (Context)
end Logos.Core.Syntax
```

**Recommendation**: Use namespace in aggregator files only if re-exporting names. Otherwise, omit namespace (pure aggregation).

### 3.2 Dependency Management

**Principle**: Minimize circular dependencies

**Strategy**:
1. **Foundation First**: Low-level definitions in separate files
2. **Single Responsibility**: Each file defines one major concept
3. **Explicit Imports**: Import only what's needed

**Bad Pattern** (circular):
```lean
-- Formula.lean
import Logos.Core.Semantics.Truth  -- Circular!

-- Truth.lean
import Logos.Core.Syntax.Formula   -- Circular!
```

**Good Pattern** (hierarchical):
```lean
-- Formula.lean (no imports from same layer)
namespace Logos.Core.Syntax
  inductive Formula : Type
end Logos.Core.Syntax

-- Truth.lean (imports from syntax, not vice versa)
import Logos.Core.Syntax.Formula
namespace Logos.Core.Semantics
  def truth_at : Formula → Prop := sorry
end Logos.Core.Semantics
```

**Recommendation**: Define dependency layers within each module:
- Syntax (bottom) → ProofSystem → Semantics → Metalogic (top)

### 3.3 Instance and Attribute Scope

**From Lean Manual**: Instances and attributes declared in namespaces are globally visible (not scoped to namespace).

**Pattern**:
```lean
namespace Logos.Core.Syntax

inductive Formula : Type
  | atom : String → Formula
  | bot : Formula

-- Instance is globally visible
instance : DecidableEq Formula := by
  sorry

end Logos.Core.Syntax

-- Instance available here too (not scoped to namespace)
```

**Implication**: Instance names should be globally unique to avoid conflicts.

**Best Practice**: Use specific instance names or anonymous instances (as shown above).

## 4. Section vs Namespace

### 4.1 When to Use Sections

**From Lean Manual** ([Namespaces and Sections](https://lean-lang.org/doc/reference/latest/Namespaces-and-Sections/)):

"Sections also allow parameters shared by many declarations to be declared centrally and propagated as needed using the `variable` command."

**Use Cases for Sections**:
1. **Shared Variables**: Multiple definitions with common parameters
2. **Scoped Options**: Temporary changes to compiler settings
3. **Local Opens**: Import namespaces locally

**Pattern**:
```lean
namespace Logos.Core.Semantics

section TaskFrameBasics
  variable {T : Type} [LinearOrderedAddCommGroup T]
  variable (F : TaskFrame T)

  -- All definitions here automatically get T and F as implicit parameters
  def example1 : WorldHistory F → Prop := sorry
  def example2 : WorldHistory F → Bool := sorry
end TaskFrameBasics

end Logos.Core.Semantics
```

**Recommendation**: Use sections for:
- Grouping related definitions with shared parameters
- Local namespace opens
- Temporary option changes

Do NOT use sections as substitute for namespaces (different purposes).

### 4.2 Nested Sections

**Pattern**:
```lean
section Outer
  variable (x : Nat)

  section Inner
    variable (y : Nat)
    -- Both x and y available here
    def example : Nat := x + y
  end Inner

  -- Only x available here
end Outer
```

**Recommendation**: Nest sections when progressively adding parameters.

## 5. Advanced Patterns for Logos

### 5.1 Type Class Hierarchy for Layers

**Scenario**: Define common interface for all task frames across layers

**Pattern**:
```lean
-- Logos/Core/Semantics/TaskFrameClass.lean
namespace Logos.Core.Semantics

class TaskFrameStructure (F : Type) (T : Type) where
  WorldState : Type
  task_rel : WorldState → T → WorldState → Prop
  nullity : ∀ w : WorldState, task_rel w 0 w

-- Core task frame instance
structure CoreTaskFrame (T : Type) [LinearOrderedAddCommGroup T] where
  WorldState : Type
  task_rel : WorldState → T → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v

instance : TaskFrameStructure (CoreTaskFrame T) T where
  WorldState := CoreTaskFrame.WorldState
  task_rel := CoreTaskFrame.task_rel
  nullity := CoreTaskFrame.nullity

end Logos.Core.Semantics
```

**Benefit**: Enables writing generic functions that work across all layer-specific task frames.

**Use Case**: Shared metalogic theorems applicable to all layers.

### 5.2 Formula Type Hierarchy

**Scenario**: Each layer extends previous layer's formula type

**Pattern** (from ARCHITECTURE.md):
```lean
-- Logos/Core/Syntax/Formula.lean
namespace Logos.Core.Syntax
  inductive Formula : Type
    | atom : String → Formula
    | bot : Formula
    | imp : Formula → Formula → Formula
    | box : Formula → Formula
    | past : Formula → Formula
    | future : Formula → Formula
end Logos.Core.Syntax

-- Logos/Explanatory/Syntax/Formula.lean
namespace Logos.Explanatory.Syntax
  inductive Formula : Type
    | core : Logos.Core.Syntax.Formula → Formula        -- Embed Core
    | boxright : Formula → Formula → Formula            -- Counterfactual
    | ground : Formula → Formula → Formula              -- Grounding

  -- Coercion from Core to Explanatory
  instance : Coe Logos.Core.Syntax.Formula Formula where
    coe := Formula.core
end Logos.Explanatory.Syntax

-- Usage:
-- Core formula automatically lifts to Explanatory context
def example : Logos.Explanatory.Syntax.Formula :=
  (Logos.Core.Syntax.Formula.atom "p")  -- Coercion implicit
```

**Benefit**: Seamless embedding of core formulas into extended formula types.

### 5.3 Parameterized Semantics Pattern

**Scenario**: Truth evaluation generic over formula type

**Pattern**:
```lean
-- Logos/Core/Semantics/Truth.lean
namespace Logos.Core.Semantics

class Evaluable (F : Type) (M : Type) where
  eval : M → F → Prop

-- Core formula evaluation
def CoreTruthEval (T : Type) [LinearOrderedAddCommGroup T] :
    Evaluable Logos.Core.Syntax.Formula (TaskModel T) where
  eval M φ := truth_at M φ

end Logos.Core.Semantics

-- Logos/Explanatory/Semantics/Truth.lean
namespace Logos.Explanatory.Semantics

-- Explanatory formula evaluation
def ExplanatoryTruthEval (T : Type) [LinearOrderedAddCommGroup T] :
    Evaluable Logos.Explanatory.Syntax.Formula (ExplanatoryModel T) where
  eval M φ := explanatory_truth_at M φ

end Logos.Explanatory.Semantics
```

**Benefit**: Unified interface for truth evaluation across layers.

### 5.4 Extension Point Pattern

**Scenario**: Core layer defines hooks for future extensions

**Pattern**:
```lean
-- Logos/Core/Syntax/ExtensionPoint.lean
namespace Logos.Core.Syntax

-- Extensible formula interface
class FormulaLike (F : Type) where
  to_core : F → Formula
  from_core : Formula → Option F

-- Core formula trivially implements interface
instance : FormulaLike Formula where
  to_core := id
  from_core := some

end Logos.Core.Syntax

-- Logos/Explanatory/Syntax/Formula.lean
namespace Logos.Explanatory.Syntax

instance : FormulaLike Formula where
  to_core
    | .core φ => φ
    | .boxright φ ψ => Logos.Core.Syntax.Formula.imp (to_core φ) (to_core ψ)  -- Conservative approximation
    | .ground φ ψ => Logos.Core.Syntax.Formula.imp (to_core φ) (to_core ψ)
  from_core φ := some (.core φ)

end Logos.Explanatory.Syntax
```

**Benefit**: Enables generic programming over different formula types.

**Use Case**: Shared tactics that work on any formula type implementing FormulaLike.

## 6. Lean 4 Naming Conventions (2025 Update)

**From Lean 4.18.0 Release** ([Lean 4.18.0](https://lean-lang.org/doc/reference/latest/releases/v4.18.0/)):

"Added a style guide and a naming convention for the standard library"

### 6.1 Naming Conventions

**Types and Structures**: `PascalCase`
```lean
structure TaskFrame
structure WorldHistory
inductive Formula
```

**Functions and Definitions**: `snake_case`
```lean
def truth_at : Formula → Prop
def task_rel : WorldState → T → WorldState → Prop
```

**Theorems**: `snake_case` (descriptive name)
```lean
theorem soundness_modal_t : ...
theorem perpetuity_p3 : ...
```

**Namespaces**: `PascalCase` (match directory structure)
```lean
namespace Logos.Core.Syntax
namespace Logos.Explanatory.Semantics
```

**Recommendation**: Follow these conventions for consistency with Lean 4 ecosystem.

### 6.2 Module Naming

**File Names**: Match namespace (PascalCase.lean)
```
Logos/Core/Syntax/Formula.lean      ↔  Logos.Core.Syntax.Formula
Logos/Core/Semantics/TaskFrame.lean ↔  Logos.Core.Semantics.TaskFrame
```

**Exception**: Aggregator files use parent namespace:
```
Logos/Core/Syntax.lean              ↔  (aggregates Logos.Core.Syntax.*)
```

## 7. Avoiding Namespace Conflicts

### 7.1 Common Conflict Patterns

**From Research** ([Resolution with duplicated namespaces](https://github.com/leanprover/lean4/issues/1224)):

"When you define two variables with exactly the same name and with different values, and then attempt to import both definitions at once, Lean treats this as an error by design."

**Problem Scenario**:
```lean
-- Package A
namespace Tactics
  def apply_axiom : Tactic := ...
end Tactics

-- Package B (conflicts!)
namespace Tactics
  def apply_axiom : Tactic := ...  -- Name collision!
end Tactics
```

**Solution**: Use project-specific prefix
```lean
-- Package A
namespace LogosTactics
  def apply_axiom : Tactic := ...
end LogosTactics

-- Package B
namespace MyProjectTactics
  def apply_axiom : Tactic := ...
end MyProjectTactics
```

### 7.2 Logos Conflict Avoidance

**Strategy**: All Logos namespaces start with `Logos.`

**Benefits**:
1. No conflicts with mathlib4 (uses `Mathlib.` prefix)
2. No conflicts with standard library (uses `Lean.` prefix)
3. No conflicts with other projects
4. Clear ownership of names

**Pattern**:
```lean
namespace Logos.Core.Syntax      -- Unambiguous
namespace Logos.Explanatory      -- Unambiguous
namespace LogosTest              -- Test namespace (separate root)
```

### 7.3 Qualified Names for Disambiguation

**Pattern**:
```lean
-- If two layers define similar concepts:
import Logos.Core.Semantics.TaskFrame
import Logos.Explanatory.Semantics.TaskFrame

-- Use qualified names to disambiguate:
def core_frame : Logos.Core.Semantics.TaskFrame := ...
def exp_frame : Logos.Explanatory.Semantics.TaskFrame := ...
```

**Recommendation**: When in doubt, use fully qualified names for clarity.

## 8. Import Organization Best Practices

### 8.1 Import Order

**Recommended Order**:
1. Standard library imports
2. Mathlib imports
3. External dependency imports
4. Project imports (same layer)
5. Project imports (other layers)

**Example**:
```lean
-- Standard library
import Lean.Data.Json

-- Mathlib
import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Set.Basic

-- Same layer
import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context

-- Other layers (if needed)
import Logos.Common.Types
```

**Benefit**: Clear dependency structure, easier to refactor.

### 8.2 Selective Importing

**Pattern**: Import only what's needed
```lean
-- Good: Specific imports
import Logos.Core.Syntax.Formula
import Logos.Core.Semantics.TaskFrame

-- Avoid: Blanket imports (unless intentional)
import Logos.Core  -- Imports everything in Core layer
```

**Exception**: Aggregator imports are acceptable for convenience:
```lean
-- In application code (not library code)
import Logos.Core  -- Convenient for end-users
```

**Recommendation**: Library code should use specific imports. Application code can use aggregator imports.

## 9. Recommended Logos Architecture

### 9.1 Directory Structure

```
Logos/                              # Root namespace
├── Logos.lean                      # Root aggregator (imports all layers)
├── Core/                           # Layer 0 namespace (Logos.Core)
│   ├── Core.lean                   # Layer aggregator
│   ├── Syntax/
│   │   ├── Syntax.lean             # Module aggregator
│   │   ├── Formula.lean            # Logos.Core.Syntax.Formula
│   │   └── Context.lean            # Logos.Core.Syntax.Context
│   ├── ProofSystem/
│   │   ├── ProofSystem.lean
│   │   ├── Axioms.lean
│   │   └── Derivation.lean
│   ├── Semantics/
│   │   ├── Semantics.lean
│   │   ├── TaskFrame.lean
│   │   ├── WorldHistory.lean
│   │   ├── TaskModel.lean
│   │   ├── Truth.lean
│   │   └── Validity.lean
│   ├── Metalogic/
│   │   ├── Metalogic.lean
│   │   ├── Soundness.lean
│   │   └── Completeness.lean
│   ├── Theorems/
│   │   ├── Theorems.lean
│   │   └── Perpetuity.lean
│   └── Automation/
│       ├── Automation.lean
│       ├── Tactics.lean
│       └── ProofSearch.lean
├── Explanatory/                    # Layer 1 (future)
│   ├── Explanatory.lean
│   ├── Syntax/
│   │   ├── Syntax.lean
│   │   └── Formula.lean
│   ├── ProofSystem/
│   │   ├── ProofSystem.lean
│   │   └── Axioms.lean
│   └── Semantics/
│       ├── Semantics.lean
│       ├── MaximalState.lean
│       ├── TaskFrame.lean
│       └── Truth.lean
├── Epistemic/                      # Layer 2 (future)
│   └── ...
└── Normative/                      # Layer 3 (future)
    └── ...
```

### 9.2 Test Directory Structure

```
LogosTest/                          # Root test namespace
├── LogosTest.lean                  # Test library root
├── Main.lean                       # Test runner
├── Core/                           # Layer 0 tests
│   ├── Syntax/
│   │   ├── FormulaTest.lean        # LogosTest.Core.Syntax.FormulaTest
│   │   └── ContextTest.lean
│   ├── ProofSystem/
│   │   ├── AxiomsTest.lean
│   │   └── DerivationTest.lean
│   ├── Semantics/
│   │   ├── TaskFrameTest.lean
│   │   └── TruthTest.lean
│   ├── Integration/
│   │   └── EndToEndTest.lean
│   ├── Metalogic/
│   │   ├── SoundnessTest.lean
│   │   └── CompletenessTest.lean
│   ├── Theorems/
│   │   └── PerpetuityTest.lean
│   └── Automation/
│       └── TacticsTest.lean
├── Explanatory/                    # Layer 1 tests (future)
│   └── ...
├── Epistemic/                      # Layer 2 tests (future)
│   └── ...
└── Normative/                      # Layer 3 tests (future)
    └── ...
```

### 9.3 Archive Directory Structure

```
Archive/                            # Pedagogical examples
├── Archive.lean                    # Archive library root
├── Core/                           # Layer 0 examples
│   ├── ModalProofs.lean
│   ├── TemporalProofs.lean
│   └── BimodalProofs.lean
├── Explanatory/                    # Layer 1 examples (future)
│   └── CounterfactualProofs.lean
├── Epistemic/                      # Layer 2 examples (future)
│   └── EpistemicProofs.lean
└── Normative/                      # Layer 3 examples (future)
    └── DeonticProofs.lean
```

## 10. Migration Path from Current Structure

### 10.1 Phase 1: Simple Rename (Minimal Disruption)

**Changes**:
```
Logos/ → Logos/
LogosTest/ → LogosTest/
Logos.lean → Logos.lean
LogosTest.lean → LogosTest.lean

namespace Logos → namespace Logos
namespace LogosTest → namespace LogosTest
```

**Benefit**: Minimal changes, easy to verify.

**Structure After Phase 1**:
```
Logos/
├── Syntax/
├── ProofSystem/
├── Semantics/
├── Metalogic/
├── Theorems/
└── Automation/
```

**Namespace**: `Logos.Syntax`, `Logos.Semantics`, etc.

### 10.2 Phase 2: Add Core Layer (Incremental Improvement)

**Changes**:
```
Logos/ → Logos/Core/
  (Move all existing modules under Core/)

Add: Logos/Core/Core.lean (aggregator)
Update: Logos.lean (import Logos.Core)
```

**Benefit**: Prepares for future layers without breaking existing structure.

**Structure After Phase 2**:
```
Logos/
└── Core/
    ├── Syntax/
    ├── ProofSystem/
    ├── Semantics/
    ├── Metalogic/
    ├── Theorems/
    └── Automation/
```

**Namespace**: `Logos.Core.Syntax`, `Logos.Core.Semantics`, etc.

### 10.3 Phase 3: Add Layer Stubs (Future Preparation)

**Changes**:
```
Add: Logos/Explanatory/ (stub)
Add: Logos/Epistemic/ (stub)
Add: Logos/Normative/ (stub)
```

**Stub Content** (Logos/Explanatory/Explanatory.lean):
```lean
-- Logos/Explanatory/Explanatory.lean
namespace Logos.Explanatory
  -- Layer 1 (Explanatory Extension)
  -- To be implemented post Core completion
end Logos.Explanatory
```

**Benefit**: Documents future extension points, reserves namespace.

**Recommendation**: Do this in Phase 2 or delay until Core layer is fully complete.

### 10.4 Recommended Timeline

**Phase 1** (Immediate):
- Rename Logos → Logos
- Update all namespaces and imports
- Verify build and tests

**Phase 2** (Soon after):
- Reorganize into Logos/Core/ layer
- Create aggregator files
- Update documentation

**Phase 3** (Optional):
- Add layer stubs
- Document extension strategy
- Create extension templates

## 11. Documentation Best Practices

### 11.1 Module Documentation

**Pattern** (from current TaskFrame.lean):
```lean
/-!
# TaskFrame - Task Frame Structure for TM Semantics

This module defines task frames, the fundamental semantic structures for bimodal logic TM.

## Main Definitions

- `TaskFrame T`: Structure with world states, times of type `T`, task relation, and constraints
- `TaskFrame.nullity`: Identity task constraint (`task_rel w 0 w`)
- `TaskFrame.compositionality`: Task composition constraint

## Main Results

- Example task frames for testing and demonstrations

## References

* [ARCHITECTURE.md](../../../Documentation/UserGuide/ARCHITECTURE.md)
* [TaskFrame Paper](https://www.example.com/paper.pdf)
-/
```

**Recommendation**: Include doc comments for:
1. Module purpose
2. Main definitions
3. Main results
4. Cross-references to documentation

### 11.2 Namespace Documentation

**Pattern**:
```lean
/-!
# Logos.Core.Syntax

This namespace contains the syntactic components of Layer 0 (Core TM logic).

## Modules

- `Formula`: Core formula inductive type with modal and temporal operators
- `Context`: Proof context management (premise lists)
-/
namespace Logos.Core.Syntax
  -- Module contents
end Logos.Core.Syntax
```

### 11.3 Cross-Layer Documentation

**Pattern**:
```lean
/-!
# Logos.Explanatory.Syntax.Formula

This module extends `Logos.Core.Syntax.Formula` with explanatory operators.

## Extension Strategy

The `ExplanatoryFormula` type embeds `Logos.Core.Syntax.Formula` as a constructor,
enabling seamless use of core formulas in explanatory contexts via coercion.

## See Also

- `Logos.Core.Syntax.Formula`: Base formula type
- `Logos.Explanatory.Semantics.Truth`: Truth evaluation for explanatory formulas
-/
```

## 12. Summary and Recommendations

### 12.1 Key Takeaways

1. **Namespace = Conceptual Organization**: Use namespaces to group logically related definitions
2. **Layers = Top-Level Namespaces**: Each Logos layer should be a top-level namespace under `Logos`
3. **Aggregator Files**: Create convenience imports at each level (layer, module, root)
4. **Explicit Imports**: Prefer specific imports in library code, aggregator imports in applications
5. **Avoid Conflicts**: Use `Logos.` prefix for all project namespaces
6. **Follow Conventions**: Use PascalCase for types/namespaces, snake_case for functions/theorems

### 12.2 Recommended Refactoring Strategy

**Step 1**: Phase 1 rename (Logos → Logos)
- Minimal disruption
- Easy to verify
- Immediate benefits

**Step 2**: Phase 2 layer organization (add Core/)
- Prepares for future extensions
- Improves structure
- Maintains compatibility

**Step 3**: Create aggregator files
- Improves usability
- Documents module boundaries
- Enables convenient imports

**Step 4**: Add layer stubs (optional)
- Documents future work
- Reserves namespaces
- Provides extension templates

### 12.3 Critical Decisions

**Decision 1: Directory Rename**
- **Recommendation**: Rename `Logos/` directory to `Logos/`
- **Rationale**: Full consistency, clearer project identity

**Decision 2: Layer Organization Timing**
- **Recommendation**: Phase 1 (simple rename) immediately, Phase 2 (Core/ layer) soon after
- **Rationale**: Incremental changes reduce risk, Phase 1 unblocks work

**Decision 3: Test Namespace**
- **Recommendation**: Use `LogosTest` as separate root namespace (not `Logos.Test`)
- **Rationale**: Clear separation between library and tests, matches Lean conventions

**Decision 4: Common Namespace**
- **Recommendation**: No `Logos.Common` namespace initially
- **Rationale**: Avoid premature abstraction, extract shared utilities only when needed

---

**Report Completion**: 2025-12-04
**Sources**:
- [Lean Manual: Namespaces](https://lean-lang.org/lean4/doc/namespaces.html)
- [Lean Reference: Namespaces and Sections](https://lean-lang.org/doc/reference/latest/Namespaces-and-Sections/)
- [Lean 4.18.0 Release Notes](https://lean-lang.org/doc/reference/latest/releases/v4.18.0/)
- [GitHub Issue: Resolution with duplicated namespaces](https://github.com/leanprover/lean4/issues/1224)
- [Stack Overflow: How to resolve namespace conflict in Lean4](https://stackoverflow.com/questions/79500457/how-to-resolve-namespace-conflict-in-lean4)
- Mathlib4 organizational patterns (observed)
- Current Logos codebase analysis

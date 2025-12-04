# Current Project Structure Analysis

**Report Date**: 2025-12-04
**Analysis Scope**: Logos repository comprehensive structure inventory
**Purpose**: Document baseline for Logos rename and layer architecture refactoring

## Executive Summary

Logos currently implements a single-namespace architecture with all TM logic (Layer 0) components under the `Logos` namespace. The refactoring will:
1. Rename the project from Logos to Logos
2. Reorganize into a layered architecture with `Logos.Core` for Layer 0
3. Create extension points for future layers (Explanatory, Epistemic, Normative)

## 1. Directory Structure

### Main Source Directories

```
Logos/                           # Root project directory
├── Logos.lean                   # Library root (re-exports all modules)
├── Logos/                       # Main source directory
│   ├── Syntax/                         # Formula types and parsing
│   │   ├── Formula.lean                # Core formula inductive type
│   │   └── Context.lean                # Proof context management
│   ├── ProofSystem/                    # Axioms and inference rules
│   │   ├── Axioms.lean                 # TM axiom schemata (8 axioms)
│   │   └── Derivation.lean             # Derivability relation and rules
│   ├── Semantics/                      # Task frame semantics
│   │   ├── TaskFrame.lean              # Task frame structure (W, T, task_rel)
│   │   ├── WorldHistory.lean           # World history functions
│   │   ├── TaskModel.lean              # Model with valuation
│   │   ├── Truth.lean                  # Truth evaluation
│   │   └── Validity.lean               # Validity and consequence
│   ├── Metalogic/                      # Soundness and completeness
│   │   ├── Soundness.lean              # Soundness theorem (complete)
│   │   └── Completeness.lean           # Completeness infrastructure
│   ├── Theorems/                       # Key theorems
│   │   └── Perpetuity.lean             # P1-P6 perpetuity principles
│   └── Automation/                     # Proof automation
│       ├── Tactics.lean                # Custom tactics (4/12 implemented)
│       └── ProofSearch.lean            # Automated proof search (planned)
├── LogosTest/                   # Test suite
│   ├── LogosTest.lean           # Test library root
│   ├── Syntax/                         # Syntax tests
│   ├── ProofSystem/                    # ProofSystem tests
│   ├── Semantics/                      # Semantics tests
│   ├── Integration/                    # Integration tests
│   ├── Metalogic/                      # Metalogic tests
│   ├── Theorems/                       # Theorem tests
│   └── Automation/                     # Automation tests
└── Archive/                            # Pedagogical examples
    ├── Archive.lean                    # Archive library root
    ├── ModalProofs.lean                # Modal logic examples
    ├── TemporalProofs.lean             # Temporal logic examples
    └── BimodalProofs.lean              # Combined examples
```

## 2. Namespace Structure

### Current Namespace Hierarchy

All Lean files use the `Logos` namespace:

```lean
-- Logos.lean (root)
namespace Logos
  -- Re-exports all public modules

-- Logos/Syntax/Formula.lean
namespace Logos.Syntax
  inductive Formula : Type
    | atom : String → Formula
    | bot : Formula
    | imp : Formula → Formula → Formula
    | box : Formula → Formula
    | past : Formula → Formula
    | future : Formula → Formula

-- Logos/Semantics/TaskFrame.lean
namespace Logos.Semantics
  structure TaskFrame (T : Type) [LinearOrderedAddCommGroup T] where
    WorldState : Type
    task_rel : WorldState → T → WorldState → Prop
    nullity : ∀ w, task_rel w 0 w
    compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v

-- Logos/Semantics/WorldHistory.lean
namespace Logos.Semantics
  structure WorldHistory (F : TaskFrame T) where
    domain : T → Prop
    convex : ∀ x z, domain x → domain z → x ≤ z → ∀ y, x ≤ y → y ≤ z → domain y
    states : (t : T) → domain t → F.WorldState
    respects_task : ∀ x y, domain x → domain y → x ≤ y →
      F.task_rel (states x hx) (y - x) (states y hy)
```

### Import Pattern Analysis

**Files Importing Logos Modules** (30+ files):
- All test files import from `Logos.*`
- Archive examples import from `Logos.*`
- Internal module dependencies follow hierarchical pattern

**Example Import Chains**:
```lean
-- Truth.lean imports TaskModel, WorldHistory, Formula
import Logos.Semantics.TaskModel
import Logos.Semantics.WorldHistory
import Logos.Syntax.Formula

-- Soundness.lean imports multiple modules
import Logos.Syntax.Formula
import Logos.ProofSystem.Derivation
import Logos.Semantics.Validity
```

## 3. Configuration Files

### lakefile.toml

```toml
name = "Logos"
version = "0.1.0"
keywords = ["logic", "modal-logic", "temporal-logic", "proof-system", "lean4"]
license = "MIT"

[[require]]
name = "mathlib"
git = "https://github.com/leanprover-community/mathlib4.git"
rev = "v4.14.0"

[[lean_lib]]
name = "Logos"

[[lean_lib]]
name = "LogosTest"

[[lean_lib]]
name = "Archive"

[[lean_exe]]
name = "test"
root = "LogosTest.Main"
```

**Impact**: Project name, library names, and test executable root all reference Logos.

### lean-toolchain

```
leanprover/lean4:v4.14.0
```

**Impact**: No direct Logos references, but version compatibility must be maintained.

## 4. Key Semantic Definitions

### TaskFrame (Core Layer Foundation)

**File**: `Logos/Semantics/TaskFrame.lean`

**Current Definition**:
```lean
structure TaskFrame (T : Type) [LinearOrderedAddCommGroup T] where
  WorldState : Type                                    -- World states (points)
  task_rel : WorldState → T → WorldState → Prop       -- Task relation
  nullity : ∀ w, task_rel w 0 w                        -- Identity constraint
  compositionality : ∀ w u v x y,                      -- Composition constraint
    task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Critical Semantic Properties**:
- `WorldState` is an abstract type (currently representing "points" in semantic space)
- Task relation connects world states via temporal durations
- Nullity ensures reflexivity (zero-duration task is identity)
- Compositionality ensures task chaining

**Layer 0 Interpretation**: World states as points (abstract atomic states)

**Future Layer 1 Interpretation**: World states as maximal possible states (structured states with internal composition)

### WorldHistory (Possible Worlds)

**File**: `Logos/Semantics/WorldHistory.lean`

**Current Definition**:
```lean
structure WorldHistory (F : TaskFrame T) where
  domain : T → Prop                                    -- Convex time domain
  convex : ∀ x z, domain x → domain z → x ≤ z →       -- Convexity constraint
    ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : T) → domain t → F.WorldState          -- Function from times to states
  respects_task : ∀ x y, domain x → domain y → x ≤ y →
    F.task_rel (states x hx) (y - x) (states y hy)    -- Task constraint
```

**Critical Semantic Properties**:
- Domain must be convex (no temporal gaps)
- Maps times to world states
- Must respect task relation (temporal evolution constraints)

**Layer Extension Impact**: The `WorldState` type parameter means different layer semantics can be supported by changing TaskFrame's WorldState interpretation.

### Truth Evaluation

**File**: `Logos/Semantics/Truth.lean`

**Current Pattern**:
```lean
def truth_at (M : TaskModel T) (τ : WorldHistory M.frame) (t : T)
  (h : τ.domain t) : Formula → Prop
  | Formula.atom p => M.valuation p τ t h
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t h φ → truth_at M τ t h ψ
  | Formula.box φ => ∀ (τ' : WorldHistory M.frame) (h' : τ'.domain t),
      truth_at M τ' t h' φ
  | Formula.past φ => ∀ (t' : T) (h' : τ.domain t'), t' < t →
      truth_at M τ t' h' φ
  | Formula.future φ => ∀ (t' : T) (h' : τ.domain t'), t < t' →
      truth_at M τ t' h' φ
```

**Layer Extension Impact**: Future layers will extend `Formula` type and add new evaluation cases.

## 5. File Count Analysis

### Lean Source Files

**Total Lean Files**: 43 (excluding .lake/ packages)
- Logos/ source: 15 files
- LogosTest/ tests: 21 files
- Archive/ examples: 4 files
- Root level: 3 files (Logos.lean, Archive.lean, LogosTest.lean)

### Files Containing "Logos" in Name or Content

**Directory/File Names**: 3 directories + multiple files
- `Logos/` (main source directory)
- `LogosTest/` (test directory)
- `Logos.lean` (root file)
- `LogosTest.lean` (test root file)

**Namespace Declarations**: 33 files with `namespace Logos`
- All main source files
- All test files
- All archive examples

**Import Statements**: 30+ files with `import Logos.*`

### Documentation Files

**Total Markdown Files**: 50+ files
- README.md (root)
- CLAUDE.md (project configuration)
- Documentation/ directory: 30+ files
- .claude/ directory: 20+ files (specs, reports, docs)

**Files Referencing "Logos"**: 40+ markdown files
- Project name in titles and descriptions
- File paths in documentation
- Command examples
- Citation information

## 6. Critical Dependencies

### Internal Module Dependencies

**Dependency Graph** (simplified):
```
Formula (Syntax)
  ↓
Context (Syntax) ← imports Formula
  ↓
Axioms (ProofSystem) ← imports Formula
Derivation (ProofSystem) ← imports Formula, Context
  ↓
TaskFrame (Semantics) ← imports Formula
WorldHistory (Semantics) ← imports TaskFrame
TaskModel (Semantics) ← imports TaskFrame, WorldHistory
Truth (Semantics) ← imports TaskModel, WorldHistory, Formula
Validity (Semantics) ← imports Truth, Derivation
  ↓
Soundness (Metalogic) ← imports Validity, Derivation
Completeness (Metalogic) ← imports Soundness, TaskFrame
  ↓
Perpetuity (Theorems) ← imports Derivation, Soundness
Tactics (Automation) ← imports Derivation, Soundness
```

**Critical Observation**: All modules ultimately depend on `Formula` (Syntax), making it the foundation for any reorganization.

### External Dependencies

**Mathlib4**: Extensive imports for:
- `Mathlib.Algebra.Order.Group.Defs` (LinearOrderedAddCommGroup)
- `Mathlib.Data.Set.Basic` (Set operations)
- `Mathlib.Logic.Basic` (Classical logic)
- `Mathlib.Order.Basic` (Order theory)

**Impact**: External dependencies are stable and won't require changes during rename/refactor.

## 7. Test Suite Organization

### Test File Pattern

**Naming Convention**: `<Module>Test.lean`
- `FormulaTest.lean` tests `Formula.lean`
- `AxiomsTest.lean` tests `Axioms.lean`
- `SoundnessTest.lean` tests `Soundness.lean`

**Test Structure Pattern**:
```lean
import Logos.Syntax.Formula
namespace LogosTest.Syntax.FormulaTest

def test_atom_construction : Bool :=
  -- test implementation
  true

def test_modal_box_diamond_duality : Bool :=
  -- test implementation
  true

#guard test_atom_construction
#guard test_modal_box_diamond_duality

end LogosTest.Syntax.FormulaTest
```

**Test Categories**:
1. **Unit Tests**: Module-level feature tests (Syntax/, ProofSystem/, Semantics/)
2. **Integration Tests**: Cross-module interaction tests (Integration/)
3. **Metalogic Tests**: Soundness/completeness property tests (Metalogic/)
4. **Theorem Tests**: Perpetuity principle proofs (Theorems/)
5. **Automation Tests**: Tactic functionality tests (Automation/)

**Total Test Files**: 21 files with 150+ individual test cases

## 8. Archive Examples

### Pedagogical Example Structure

**Files**:
- `ModalProofs.lean`: S5 modal logic examples (necessity, possibility)
- `TemporalProofs.lean`: Temporal logic examples (past, future)
- `BimodalProofs.lean`: Combined modal-temporal examples (perpetuity principles)

**Pattern**:
```lean
import Logos

namespace Archive.ModalProofs

-- Example 1: Modal T axiom (□φ → φ)
def example_modal_t : Derivable [] (Formula.box p).imp p := by
  apply Derivable.axiom
  exact Axiom.modal_t p

-- Example 2: Diamond-Box duality
theorem diamond_box_duality (φ : Formula) :
  Derivable [] ((diamond φ).imp (neg (Formula.box (neg φ)))) := by
  -- proof implementation
  sorry

end Archive.ModalProofs
```

**Usage**: Educational resources demonstrating library functionality for newcomers.

## 9. Build Artifacts

### .lake/ Directory Structure

```
.lake/
├── build/
│   ├── lib/Logos/          # Compiled library files
│   ├── ir/Logos/            # Intermediate representation
│   └── doc/                        # Generated documentation
└── packages/
    ├── mathlib/                    # External dependency
    └── aesop/                      # External dependency
```

**Impact**: Build artifacts reference Logos namespace and will be regenerated during refactor.

## 10. CI/CD Configuration

### GitHub Workflows

**File**: `.github/workflows/ci.yml` (if exists)

**Expected Pattern**:
```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Logos
        run: lake build
      - name: Run tests
        run: lake test
```

**Impact**: Workflow names and job descriptions reference project name.

## 11. Git Repository State

### Current Branch

**Branch**: `main`
**Status**: Modified files (from git status)
- Multiple modified .md files (documentation updates)
- Modified .lean files (semantics updates)
- Untracked directories (.claude/specs/034-036, .claude/tmp/ files)

### Recent Commits

```
df69032 updated project info
024f79b updated commands
90ce514 updated README
7e2b418 updated lean commands
b159d2d finished soundness
```

**Observation**: Recent work focused on soundness completion and documentation updates.

## 12. Refactoring Impact Assessment

### High-Impact Changes

1. **Namespace Renaming**: All 33 Lean files with `namespace Logos`
2. **Import Statements**: All 30+ files importing from `Logos.*`
3. **File/Directory Names**: 3 directories + root files need renaming
4. **lakefile.toml**: Library names and package configuration
5. **Documentation**: 40+ markdown files with project name references

### Medium-Impact Changes

1. **Test Suite**: Test namespace declarations and imports
2. **Archive Examples**: Import statements and namespace declarations
3. **CLAUDE.md**: Project configuration references
4. **README.md**: Project name, structure diagrams, command examples
5. **Build Scripts**: Any automation referencing project name

### Low-Impact Changes

1. **Git History**: Commit messages retain original name (no change needed)
2. **External Dependencies**: Mathlib imports unchanged
3. **Lean Toolchain**: Version specification unchanged
4. **.gitignore**: Build artifact patterns may need updating

## 13. Layer Architecture Preparation

### Core Layer (Layer 0) Components

**All existing Logos modules become Logos.Core**:
- `Logos.Core.Syntax` (Formula, Context)
- `Logos.Core.ProofSystem` (Axioms, Derivation)
- `Logos.Core.Semantics` (TaskFrame, WorldHistory, TaskModel, Truth, Validity)
- `Logos.Core.Metalogic` (Soundness, Completeness)
- `Logos.Core.Theorems` (Perpetuity)
- `Logos.Core.Automation` (Tactics, ProofSearch)

### Future Layer Extension Points

**Layer 1 (Explanatory)** - Future:
- `Logos.Explanatory.Syntax` (Extended formula with counterfactuals)
- `Logos.Explanatory.Semantics` (Selection functions, maximal states)
- `Logos.Explanatory.ProofSystem` (Counterfactual axioms)

**Layer 2 (Epistemic)** - Future:
- `Logos.Epistemic.Syntax` (Belief, probability operators)
- `Logos.Epistemic.Semantics` (Information states, accessibility)
- `Logos.Epistemic.ProofSystem` (Epistemic axioms)

**Layer 3 (Normative)** - Future:
- `Logos.Normative.Syntax` (Obligation, permission, preference)
- `Logos.Normative.Semantics` (Ideality ordering, preference relations)
- `Logos.Normative.ProofSystem` (Deontic axioms)

### Shared Infrastructure

**Logos.Common** (if needed):
- Shared utilities across layers
- Common type classes
- Cross-layer integration support

## 14. Critical Semantic Differences Noted

### Layer 0 (Core) - Current Implementation

**WorldState Interpretation**: Abstract points
- World states are primitive atomic entities
- No internal structure assumed
- Task relation operates on point-to-point transitions

### Layer 1 (Explanatory) - Future Implementation

**WorldState Interpretation**: Maximal possible states
- World states have internal composition (verifier/falsifier pairs)
- Structured states support grounding relations
- Counterfactual evaluation requires similarity ordering on states

**Critical Change**: The `TaskFrame.WorldState` type parameter enables this transition, but the semantics modules will need layer-specific implementations:
- `Logos.Core.Semantics.TaskFrame` (points-based, current)
- `Logos.Explanatory.Semantics.TaskFrame` (maximal-states-based, future)

**Implication**: WorldHistory definition may need layer-specific versions or parameterization over state structure.

## 15. Recommendations

### Refactoring Strategy

1. **Phase 1**: Rename project infrastructure (lakefile.toml, directories, root files)
2. **Phase 2**: Update namespaces systematically (Core layer grouping)
3. **Phase 3**: Update all imports and references
4. **Phase 4**: Update documentation and configuration files
5. **Phase 5**: Verify build and test suite
6. **Phase 6**: Create layer extension templates/stubs

### Risk Mitigation

1. **Create Git Branch**: Work on `feature/logos-layer-architecture` branch
2. **Incremental Commits**: Commit after each phase for easy rollback
3. **Test After Each Phase**: Ensure `lake build` and `lake test` pass
4. **Documentation Updates**: Update docs immediately after code changes
5. **Backup Current State**: Archive current Logos structure

### Critical Path Items

1. **lakefile.toml Changes**: Must be correct for build system to work
2. **Namespace Hierarchy**: Must maintain dependency order during rename
3. **Import Statement Updates**: Must be complete to avoid compilation errors
4. **Test Suite Compatibility**: All tests must pass after refactor
5. **Documentation Accuracy**: All references must be updated for consistency

---

**Report Completion**: 2025-12-04
**Next Report**: 002-layer-architecture-requirements.md

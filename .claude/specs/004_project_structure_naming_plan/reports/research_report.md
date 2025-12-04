# Project Structure and Naming Conventions Research Report

**Project**: Logos
**Research Date**: 2025-12-01
**Research Complexity**: 3
**Researcher**: Claude (research-specialist agent)

---

## Executive Summary

This report analyzes the current Logos project structure against LEAN 4 community standards (primarily mathlib4 and std4) to determine optimal file and directory naming conventions. The research reveals significant misalignment between the current planned structure in CLAUDE.md and LEAN 4 community standards, particularly regarding directory naming conventions.

**Key Findings**:
1. LEAN 4 uses **PascalCase** (UpperCamelCase) for all files and directories
2. Current Logos plan uses inconsistent casing with PascalCase directories (Logos/, Syntax/, ProofSystem/, etc.)
3. User preference for snake_case lowercase directories conflicts with LEAN 4 community standards
4. Test directories in mathlib4 use PascalCase (MathlibTest, not Tests or tests)
5. Example directories in mathlib4 use PascalCase (Counterexamples, Archive, not Examples)

---

## 1. Current Project State Analysis

### 1.1 Current Directory Structure

From examination of `/home/benjamin/Documents/Philosophy/Projects/Logos/`:

```
Logos/
├── .claude/
├── .github/
├── .git/
├── CLAUDE.md
├── README.md
├── docs/
├── lakefile.toml
├── lean-toolchain
└── src/
    └── docs/
```

**Status**: Only documentation directories exist; no LEAN source code implemented yet.

### 1.2 Planned Structure (from CLAUDE.md)

```
Logos/
├── Logos.lean           # Library root
├── Logos/               # Main source directory
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Metalogic/
│   ├── Theorems/
│   └── Automation/
├── Examples/
│   ├── ModalProofs.lean
│   ├── TemporalProofs.lean
│   └── BimodalProofs.lean
├── Tests/
│   ├── Unit/
│   ├── Integration/
│   └── Metalogic/
├── docs/
└── src/docs/
```

### 1.3 Lakefile Configuration

From `/home/benjamin/Documents/Philosophy/Projects/Logos/lakefile.toml`:

```toml
[[lean_lib]]
name = "Logos"
roots = ["Logos"]
globs = ["Logos/**"]

[[lean_lib]]
name = "Examples"
roots = ["Examples"]
globs = ["Examples/**"]

[[lean_exe]]
name = "tests"
root = "Tests"
```

**Analysis**: The lakefile expects PascalCase directories (Logos, Examples, Tests).

---

## 2. LEAN 4 Community Standards Research

### 2.1 File Naming Conventions

**Source**: [Lean Community Naming Conventions](https://leanprover-community.github.io/contribute/naming.html)

#### Files
- **Standard**: Files use **UpperCamelCase** (PascalCase)
- **Rare exceptions**: Specifically lower-cased mathematical objects (e.g., `lp.lean` for the space ℓₚ) require Zulip discussion first
- **Examples**:
  - `Formula.lean` ✓
  - `TaskFrame.lean` ✓
  - `Soundness.lean` ✓
  - `formula.lean` ✗ (violates standard)

#### Spelling
- **Standard**: American English spelling (e.g., `factorization` not `factorisation`)

### 2.2 Declaration Naming Conventions

**Capitalization Rules** (blends three casing styles):

1. **Propositions and proofs**: `snake_case`
   - Example: `map_one'`, `modal_t_valid`

2. **Inductive types, structures, classes**: `UpperCamelCase`
   - Example: `Formula`, `TaskFrame`, `OneHom`

3. **Functions**: Named by their return type's casing convention

4. **Other terms**: `lowerCamelCase`

5. **Namespace references**: When `UpperCamelCase` names appear in `snake_case` contexts, they convert to `lowerCamelCase`

6. **Acronyms**: Treated as groups (e.g., `LE` vs `Ne`)

**Examples from Mathlib**:
```lean
-- Structure (UpperCamelCase)
structure OneHom where
  map_one' : ...  -- Field/proof (snake_case)

-- Theorem (snake_case)
theorem neZero_iff : ...

-- Combined
theorem MonoidHom.toOneHom_injective : ...
```

### 2.3 Directory Structure Standards

**Source**: Analysis of [mathlib4 repository](https://github.com/leanprover-community/mathlib4)

#### Main Source Directories (PascalCase)

From mathlib4 root:
```
Mathlib/
├── Algebra/
├── AlgebraicGeometry/
├── AlgebraicTopology/
├── Analysis/
├── CategoryTheory/
├── Combinatorics/
├── Computability/
├── Data/
├── Dynamics/
├── FieldTheory/
├── Geometry/
├── GroupTheory/
├── InformationTheory/
├── LinearAlgebra/
├── Logic/
├── MeasureTheory/
├── ModelTheory/
├── NumberTheory/
├── Order/
├── Probability/
├── RepresentationTheory/
├── RingTheory/
├── SetTheory/
└── Topology/
```

**Pattern**: All directories use **PascalCase** (UpperCamelCase).

#### Test and Example Directories

From mathlib4 root:
```
├── Archive/              # Historical/famous theorem examples
├── Counterexamples/      # Counterexample constructions
├── MathlibTest/          # Test suite
└── DownstreamTest/       # Downstream dependency tests
```

**Key Observations**:
- Test directory: `MathlibTest` (NOT `Tests`, `Test`, or `tests`)
- Examples: `Archive`, `Counterexamples` (NOT `Examples`)
- All use **PascalCase**

### 2.4 Module Organization Standards

**Source**: [Lean Community Style Guidelines](https://leanprover-community.github.io/contribute/style.html)

#### File Structure
1. **Copyright header** with authors and license
2. **Imports** immediately after header (no line break)
3. **Module docstring** (markdown formatted, indented 2 spaces for multi-line)
4. **Declarations** flush-left (no indentation for top-level)

#### Namespace Conventions
- Namespaces mirror directory structure
- File `Mathlib/Algebra/Group/Defs.lean` → namespace `Mathlib.Algebra.Group`
- Module path: `import Mathlib.Algebra.Group.Defs`

#### Maximum Line Length
- **Standard**: 100 characters

---

## 3. Comparative Analysis

### 3.1 Current vs. Standard Comparison

| Aspect | Current Plan | LEAN 4 Standard | Alignment |
|--------|--------------|-----------------|-----------|
| **Main source directory** | `Logos/` | PascalCase | ✓ ALIGNED |
| **Subdirectories** | `Syntax/`, `ProofSystem/`, `Semantics/` | PascalCase | ✓ ALIGNED |
| **Test directory** | `Tests/` | `MathlibTest` pattern | ⚠ PARTIAL |
| **Examples directory** | `Examples/` | `Archive`/`Counterexamples` | ⚠ PARTIAL |
| **File names** | `.lean` files | PascalCase | ✓ ALIGNED |
| **Documentation** | `docs/`, `src/docs/` | lowercase docs | ✓ ALIGNED |
| **Root files** | `Logos.lean` | PascalCase | ✓ ALIGNED |

### 3.2 User Preference vs. Standard

**User stated preference**: "I prefer lower case project directory names in snake_case but want to follow what is most standard."

**Analysis**:
- LEAN 4 community standard is **PascalCase** for all source directories
- snake_case is NOT standard for LEAN 4 directories
- Deviation from standard would create inconsistency with ecosystem
- **Recommendation**: Follow LEAN 4 standard (PascalCase) over personal preference

### 3.3 Gap Analysis

#### Gaps Identified

1. **Test Directory Naming**
   - Current: `Tests/`
   - Standard: `LogosTest/` or `Test/` (following mathlib4 pattern)
   - Gap: Plural form inconsistent with mathlib4

2. **Examples Directory Organization**
   - Current: `Examples/` (monolithic)
   - Standard: Separate categories like `Archive/`, `Counterexamples/`
   - Gap: No semantic categorization

3. **Documentation Directory**
   - Current: `docs/` and `src/docs/`
   - Standard: lowercase for non-LEAN content
   - Status: ✓ Already aligned

4. **Nested Test Structure**
   - Current: `Tests/Unit/`, `Tests/Integration/`
   - Standard: Flat or minimal nesting (e.g., `MathlibTest/`)
   - Gap: Potentially over-nested

---

## 4. Recommended Structure

### 4.1 Proposed Directory Structure

Based on LEAN 4 standards and mathlib4 patterns:

```
Logos/                      # Root project directory
├── Logos.lean              # Library root (re-exports)
├── Logos/                  # Main source library
│   ├── Syntax/
│   │   ├── Formula.lean
│   │   ├── Context.lean
│   │   ├── Operators.lean
│   │   └── DSL.lean
│   ├── ProofSystem/
│   │   ├── Axioms.lean
│   │   ├── Rules.lean
│   │   └── Derivation.lean
│   ├── Semantics/
│   │   ├── TaskFrame.lean
│   │   ├── WorldHistory.lean
│   │   ├── TaskModel.lean
│   │   ├── Truth.lean
│   │   ├── Validity.lean
│   │   └── Canonical.lean
│   ├── Metalogic/
│   │   ├── Soundness.lean
│   │   ├── Completeness.lean
│   │   ├── Decidability.lean
│   │   └── Interpolation.lean
│   ├── Theorems/
│   │   ├── Perpetuity.lean
│   │   └── Basic.lean
│   └── Automation/
│       ├── Tactics.lean
│       ├── ProofSearch.lean
│       └── Templates.lean
├── LogosTest/              # Test suite (NOT Tests/)
│   ├── LogosTest.lean     # Test library root
│   ├── Syntax/                    # Mirror main structure
│   │   ├── FormulaTest.lean
│   │   └── ContextTest.lean
│   ├── ProofSystem/
│   │   ├── AxiomsTest.lean
│   │   └── DerivationTest.lean
│   ├── Semantics/
│   │   ├── TaskFrameTest.lean
│   │   └── TruthTest.lean
│   ├── Integration/
│   │   ├── SoundnessTest.lean
│   │   └── CompletenessTest.lean
│   └── Metalogic/
│       └── ConsistencyTest.lean
├── Archive/                       # Historical/pedagogical examples
│   ├── Archive.lean               # Archive library root
│   ├── ModalProofs.lean
│   ├── TemporalProofs.lean
│   └── BimodalProofs.lean
├── Counterexamples/               # Counterexample constructions
│   ├── Counterexamples.lean
│   └── Invalidity.lean
├── docs/                          # User documentation (lowercase)
│   ├── ARCHITECTURE.md
│   ├── TUTORIAL.md
│   ├── EXAMPLES.md
│   ├── CONTRIBUTING.md
│   ├── INTEGRATION.md
│   └── VERSIONING.md
├── .claude/                       # Project-specific (lowercase)
├── .github/                       # GitHub config (lowercase)
├── lakefile.toml                  # Lake build config
├── lean-toolchain                 # LEAN version
├── CLAUDE.md                      # Project instructions
├── README.md                      # Project readme
└── .gitignore
```

### 4.2 Rationale for Changes

1. **`Tests/` → `LogosTest/`**
   - Follows mathlib4 pattern (`MathlibTest`)
   - Singular form consistent with LEAN 4
   - Project-prefixed for clarity

2. **`Examples/` → `Archive/` + `Counterexamples/`**
   - Semantic categorization like mathlib4
   - `Archive/`: Pedagogical examples, famous proofs
   - `Counterexamples/`: Invalidity demonstrations, edge cases
   - More discoverable and organized

3. **Keep `Logos/` subdirectories as PascalCase**
   - Already aligned with standard
   - No changes needed

4. **Test file naming: `*Test.lean` not `*Tests.lean`**
   - Singular form consistent with structure names
   - Example: `FormulaTest.lean` not `FormulaTests.lean`

5. **Remove `src/docs/`, relocate to top-level `docs/developer/`**
   - Consolidate documentation
   - OR: Keep if wanting separation between user and developer docs

### 4.3 Alternative: Minimal Change Structure

If preferring minimal disruption to existing planning:

```
Logos/
├── Logos.lean
├── Logos/              # No change
│   ├── Syntax/                # No change
│   ├── ProofSystem/           # No change
│   ├── Semantics/             # No change
│   ├── Metalogic/             # No change
│   ├── Theorems/              # No change
│   └── Automation/            # No change
├── Test/                      # Changed: Tests → Test (singular)
│   ├── Unit/
│   ├── Integration/
│   └── Metalogic/
├── Example/                   # Changed: Examples → Example (singular)
│   ├── ModalProofs.lean
│   ├── TemporalProofs.lean
│   └── BimodalProofs.lean
├── docs/
└── lakefile.toml
```

**Trade-offs**:
- ✓ Less disruption to existing plans
- ✓ Simpler migration
- ✗ Still deviates from mathlib4 naming patterns
- ✗ Less semantic organization for examples

---

## 5. Lakefile Configuration Updates

### 5.1 Recommended Lakefile (lakefile.toml)

```toml
# lakefile.toml - LEAN 4 Build Configuration for Logos

[package]
name = "Logos"
version = "0.1.0"
keywords = ["logic", "modal-logic", "temporal-logic", "proof-system", "lean4"]
license = "MIT"
description = "LEAN 4 implementation of axiomatic proof system for bimodal logic TM with task semantics"

[build]
buildType = "debug"
precompileModules = true

# Main library
[[lean_lib]]
name = "Logos"
roots = ["Logos"]
globs = ["Logos/**"]

# Test suite
[[lean_lib]]
name = "LogosTest"
roots = ["LogosTest"]
globs = ["LogosTest/**"]

# Examples - Archive
[[lean_lib]]
name = "Archive"
roots = ["Archive"]
globs = ["Archive/**"]

# Examples - Counterexamples
[[lean_lib]]
name = "Counterexamples"
roots = ["Counterexamples"]
globs = ["Counterexamples/**"]

# Test executable
[[lean_exe]]
name = "test"
root = "LogosTest"

# Dependencies
# [[require]]
# name = "mathlib"
# scope = "leanprover-community"
# rev = "master"
```

### 5.2 Alternative Minimal Change Lakefile

```toml
# Minimal change from current plan

[[lean_lib]]
name = "Logos"
roots = ["Logos"]
globs = ["Logos/**"]

[[lean_lib]]
name = "Test"                    # Changed from "tests"
roots = ["Test"]                 # Changed from "Tests"
globs = ["Test/**"]

[[lean_lib]]
name = "Example"                 # Changed from "Examples"
roots = ["Example"]              # Changed from "Examples"
globs = ["Example/**"]

[[lean_exe]]
name = "test"                    # Executable name
root = "Test"
```

---

## 6. Migration Path

### 6.1 Current State Assessment

**Status**: Project is in early planning phase; no LEAN source code implemented.

**Advantage**: Perfect time to establish correct structure before implementation.

### 6.2 Recommended Migration Steps

Since no LEAN code exists yet, this is actually a **pre-implementation structure setup**:

#### Phase 1: Structure Establishment (Immediate)

1. **Create main source directory**:
   ```bash
   mkdir -p Logos/Syntax
   mkdir -p Logos/ProofSystem
   mkdir -p Logos/Semantics
   mkdir -p Logos/Metalogic
   mkdir -p Logos/Theorems
   mkdir -p Logos/Automation
   ```

2. **Create test directory** (recommended naming):
   ```bash
   mkdir -p LogosTest/Syntax
   mkdir -p LogosTest/ProofSystem
   mkdir -p LogosTest/Semantics
   mkdir -p LogosTest/Integration
   mkdir -p LogosTest/Metalogic
   ```

3. **Create example directories**:
   ```bash
   mkdir -p Archive
   mkdir -p Counterexamples
   ```

4. **Update lakefile.toml** with recommended configuration (Section 5.1)

5. **Create root files**:
   ```bash
   touch Logos.lean
   touch LogosTest/LogosTest.lean
   touch Archive/Archive.lean
   touch Counterexamples/Counterexamples.lean
   ```

#### Phase 2: Documentation Updates

1. **Update CLAUDE.md** with corrected structure
2. **Update docs/ARCHITECTURE.md** with corrected structure
3. **Update src/docs/MODULE_ORGANIZATION.md** with corrected structure
4. **Commit changes** with clear message about alignment with LEAN 4 standards

#### Phase 3: Validation

1. **Run lake build** to verify structure works
2. **Check imports** work correctly
3. **Verify namespace hierarchy** aligns with directory structure

### 6.3 If Preferring Minimal Change

If opting for minimal change (singular Test/Example instead of LogosTest/Archive):

1. **Create directories**:
   ```bash
   mkdir -p Test/Unit/Syntax Test/Unit/ProofSystem Test/Unit/Semantics
   mkdir -p Test/Integration Test/Metalogic
   mkdir -p Example
   ```

2. **Update lakefile.toml** with alternative configuration (Section 5.2)

3. **Update documentation** accordingly

---

## 7. Namespace Alignment

### 7.1 Current Namespace Plan

From MODULE_ORGANIZATION.md and CLAUDE.md:

```lean
namespace Logos

namespace Logos.Syntax
-- ...
end Logos.Syntax

namespace Logos.ProofSystem
-- ...
end Logos.ProofSystem

-- etc.
```

**Status**: ✓ Already aligned with LEAN 4 standards

### 7.2 Test Namespace Recommendations

```lean
-- In LogosTest/Syntax/FormulaTest.lean
namespace LogosTest.Syntax

-- Tests for Formula
def test_formula_complexity : TestResult := ...

end LogosTest.Syntax
```

Alternative if using `Test/` directory:
```lean
-- In Test/Unit/Syntax/FormulaTest.lean
namespace Test.Unit.Syntax

-- Tests
def test_formula_complexity : TestResult := ...

end Test.Unit.Syntax
```

### 7.3 Example Namespace Recommendations

```lean
-- In Archive/ModalProofs.lean
namespace Archive.ModalProofs

open Logos.Syntax
open Logos.ProofSystem

-- Examples
example (P : Formula) : ⊢ (P.box.imp P) := by
  apply Derivable.axiom
  apply Axiom.modal_t

end Archive.ModalProofs
```

---

## 8. File Naming Standards Summary

### 8.1 LEAN Source Files

**Standard**: PascalCase (UpperCamelCase)

| ✓ Correct | ✗ Incorrect |
|-----------|-------------|
| `Formula.lean` | `formula.lean` |
| `TaskFrame.lean` | `task_frame.lean` |
| `Soundness.lean` | `soundness.lean` |
| `ProofSearch.lean` | `proof_search.lean` |
| `FormulaTest.lean` | `formula_test.lean` |

### 8.2 Documentation Files

**Standard**: Can use lowercase, often UPPERCASE for convention files

| ✓ Correct | Context |
|-----------|---------|
| `README.md` | Project readme (convention) |
| `ARCHITECTURE.md` | Major documentation (convention) |
| `CLAUDE.md` | Project instructions (convention) |
| `lakefile.toml` | Build config (Lake requirement) |
| `lean-toolchain` | Version file (Lake requirement) |
| `.gitignore` | Git config (Git convention) |

### 8.3 Directory Naming

**Standard**: PascalCase for LEAN source directories, lowercase for meta directories

| Directory Type | Standard | Example |
|----------------|----------|---------|
| LEAN source | PascalCase | `Logos/`, `Syntax/` |
| LEAN tests | PascalCase | `LogosTest/` or `Test/` |
| LEAN examples | PascalCase | `Archive/`, `Counterexamples/` |
| Documentation | lowercase | `docs/` |
| Git config | lowercase | `.git/`, `.github/` |
| Project meta | lowercase | `.claude/` |

---

## 9. Key Recommendations

### 9.1 Critical Changes Required

1. **Directory Naming**:
   - Use PascalCase for all LEAN source directories
   - Already compliant: `Logos/`, `Syntax/`, etc.

2. **Test Directory**:
   - **Recommended**: `LogosTest/` (follows mathlib4 pattern)
   - **Alternative**: `Test/` (singular, minimal change)
   - **Avoid**: `Tests/`, `tests/`, `test/`

3. **Examples Organization**:
   - **Recommended**: Split into `Archive/` and `Counterexamples/`
   - **Alternative**: Use `Example/` (singular)
   - **Avoid**: `Examples/`, `examples/`

### 9.2 Best Practices to Adopt

1. **File Naming**: Always use PascalCase for `.lean` files
2. **Module Structure**: Mirror directory structure with namespaces
3. **Test Naming**: Use `*Test.lean` suffix (singular)
4. **Lakefile Alignment**: Ensure lakefile matches directory structure
5. **Documentation**: Keep lowercase for non-LEAN files (`docs/`)

### 9.3 User Preference Resolution

**User Preference**: "lower case project directory names in snake_case"

**Recommendation**: **Override preference to follow LEAN 4 standards**

**Rationale**:
- LEAN 4 ecosystem uses PascalCase universally
- Deviation creates friction with tooling and community expectations
- User explicitly stated "want to follow what is most standard"
- Personal preference should yield to ecosystem standards for better maintainability

**Compromise**:
- Keep non-LEAN directories lowercase (`.claude/`, `docs/`, `.github/`)
- Use PascalCase only for LEAN source directories
- This balances user preference with LEAN 4 requirements

---

## 10. Conclusion

### 10.1 Summary of Findings

The Logos project's planned structure is **largely aligned** with LEAN 4 community standards, with a few notable exceptions:

**Already Compliant**:
- ✓ Main source directory (`Logos/`)
- ✓ Subdirectory naming (`Syntax/`, `ProofSystem/`, etc.)
- ✓ File naming conventions (PascalCase)
- ✓ Namespace structure
- ✓ Documentation directory naming

**Requires Adjustment**:
- ⚠ Test directory: `Tests/` → `LogosTest/` or `Test/`
- ⚠ Examples directory: `Examples/` → `Archive/` + `Counterexamples/` or `Example/`
- ⚠ Test file naming: Consider `*Test.lean` suffix consistency

### 10.2 Recommended Action Plan

**Priority 1** (High Impact, Pre-Implementation):
1. Decide on test directory name: `LogosTest/` (recommended) or `Test/` (minimal)
2. Decide on examples organization: `Archive/` + `Counterexamples/` (recommended) or `Example/` (minimal)
3. Create directory structure before starting implementation
4. Update lakefile.toml accordingly
5. Update all documentation (CLAUDE.md, ARCHITECTURE.md, MODULE_ORGANIZATION.md)

**Priority 2** (Medium Impact):
1. Establish test file naming convention (`*Test.lean`)
2. Create root files for each library (`Logos.lean`, `LogosTest.lean`, etc.)
3. Document namespace conventions clearly

**Priority 3** (Low Impact, Can Evolve):
1. Consider consolidating `docs/` and `src/docs/` structure
2. Establish internal vs. public API patterns
3. Define module size limits and split policies

### 10.3 Final Structure Recommendation

**Recommended Structure** (Best alignment with LEAN 4 standards):

```
Logos/
├── Logos.lean
├── Logos/          # Main library (PascalCase subdirs)
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Metalogic/
│   ├── Theorems/
│   └── Automation/
├── LogosTest/      # Test suite (NOT Tests)
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Integration/
│   └── Metalogic/
├── Archive/               # Pedagogical examples (NOT Examples)
├── Counterexamples/       # Invalidity demonstrations
├── docs/                  # Documentation (lowercase)
├── lakefile.toml
├── lean-toolchain
└── CLAUDE.md
```

This structure:
- Follows mathlib4 patterns exactly
- Uses PascalCase for all LEAN source directories
- Semantically organizes examples into Archive/Counterexamples
- Keeps meta/docs directories lowercase
- Enables smooth integration with LEAN 4 tooling and ecosystem

---

## References

1. [Mathlib Naming Conventions](https://leanprover-community.github.io/contribute/naming.html) - Official LEAN 4 naming standards
2. [Library Style Guidelines](https://leanprover-community.github.io/contribute/style.html) - LEAN 4 style guide
3. [Mathlib4 Repository](https://github.com/leanprover-community/mathlib4) - Reference implementation
4. [Lean Projects Guide](https://leanprover-community.github.io/install/project.html) - Project setup guide
5. [Logos CLAUDE.md](file:///home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md) - Current project configuration
6. [Logos ARCHITECTURE.md](file:///home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md) - Architecture specification
7. [Logos MODULE_ORGANIZATION.md](file:///home/benjamin/Documents/Philosophy/Projects/Logos/src/docs/MODULE_ORGANIZATION.md) - Current module organization plan

---

## Appendix A: Mathlib4 Structure Examples

### Top-Level Mathlib4 Directories

```
Mathlib/
├── Algebra/              # Algebraic structures
├── AlgebraicGeometry/    # Algebraic geometry
├── AlgebraicTopology/    # Algebraic topology
├── Analysis/             # Mathematical analysis
├── CategoryTheory/       # Category theory
├── Combinatorics/        # Combinatorics
├── Data/                 # Data structures
├── FieldTheory/          # Field theory
├── Geometry/             # Geometry
├── GroupTheory/          # Group theory
├── LinearAlgebra/        # Linear algebra
├── Logic/                # Mathematical logic
├── NumberTheory/         # Number theory
├── Order/                # Order theory
├── SetTheory/            # Set theory
└── Topology/             # Topology
```

All use PascalCase, no snake_case directories.

### Mathlib4 Test and Example Structure

```
mathlib4/
├── Mathlib/              # Main library
├── MathlibTest/          # Test suite (NOT Tests)
├── Archive/              # Historical examples
├── Counterexamples/      # Counterexample constructions
└── DownstreamTest/       # Dependency tests
```

Pattern: Singular or compound PascalCase names.

---

## Appendix B: Decision Matrix

| Criteria | Current Plan | Recommended | Alternative (Minimal) | Score |
|----------|--------------|-------------|----------------------|-------|
| **Alignment with mathlib4** | Partial | ★★★★★ | ★★★☆☆ | Recommended wins |
| **LEAN 4 convention compliance** | High | ★★★★★ | ★★★★☆ | Both good |
| **Migration effort** | N/A | ★★★★★ (pre-impl) | ★★★★★ (pre-impl) | Tie |
| **Semantic clarity** | ★★★☆☆ | ★★★★★ | ★★★☆☆ | Recommended wins |
| **User preference alignment** | ★★☆☆☆ | ★★☆☆☆ | ★★☆☆☆ | Tie (standards override) |
| **Ecosystem integration** | ★★★★☆ | ★★★★★ | ★★★★☆ | Recommended wins |
| **Long-term maintainability** | ★★★★☆ | ★★★★★ | ★★★★☆ | Recommended wins |

**Recommendation**: Choose **Recommended** structure for best alignment with LEAN 4 ecosystem.

---

**Report End**

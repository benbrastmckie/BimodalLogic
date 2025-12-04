# File Structure Research Report: Logos Refactoring

## Executive Summary

This report analyzes the current Logos project structure and provides research-based recommendations for refactoring the directory organization to align with Lean 4 conventions and improve maintainability. The research identifies three main issues:

1. **Directory naming inconsistency**: Current mix of PascalCase (`Archive`, `Counterexamples`) and lowercase (`docs`, `src`) directories
2. **Dual documentation structure**: User docs in `docs/` vs developer standards in `src/docs/`
3. **Examples organization**: Need for a central `Examples/` directory following Mathlib4 patterns

## 1. Current Project Structure Analysis

### 1.1 Directory Inventory

```
Logos/
├── Archive/                    # Pedagogical examples (1 file)
├── Counterexamples/           # Invalidity demonstrations (1 file)
├── docs/                      # User documentation (6 files)
├── src/docs/                  # Developer standards (6 files)
├── Logos/              # Main library (6 subdirs: Automation, Metalogic, ProofSystem, Semantics, Syntax, Theorems)
├── LogosTest/          # Test suite (5 subdirs: Integration, Metalogic, ProofSystem, Semantics, Syntax)
├── Logos.lean          # Library root
├── lakefile.toml              # Build configuration
├── lean-toolchain             # Lean version
└── README.md
```

### 1.2 Current Lake Configuration

The `lakefile.toml` defines four libraries:
- `Logos` (main library)
- `LogosTest` (test suite)
- `Archive` (pedagogical examples)
- `Counterexamples` (invalidity demonstrations)

### 1.3 Content Analysis

#### Archive/ Directory
Contains `Archive.lean` with module documentation describing:
- **Purpose**: Pedagogical examples, famous proofs, historical examples
- **Planned structure**: `ModalProofs.lean`, `TemporalProofs.lean`, `BimodalProofs.lean`
- **Pattern**: Follows Mathlib4's Archive pattern for learning, reference, and demonstration

#### Counterexamples/ Directory
Contains `Counterexamples.lean` with module documentation describing:
- **Purpose**: Demonstrate limits and boundaries of TM logic
- **Categories**: Invalidity demonstrations, independence results, edge cases
- **Pattern**: Follows Mathlib4's Counterexamples pattern for verification and education

#### docs/ Directory (User Documentation)
Contains 6 markdown files:
- `ARCHITECTURE.md` - System design and TM logic specification (51KB)
- `CONTRIBUTING.md` - Contribution guidelines (6.6KB)
- `EXAMPLES.md` - Usage examples (10.4KB)
- `INTEGRATION.md` - Model-Checker integration (11.7KB)
- `TUTORIAL.md` - Getting started guide (9.4KB)
- `VERSIONING.md` - Versioning policy (7KB)

#### src/docs/ Directory (Developer Standards)
Contains 6 markdown files + empty README:
- `LEAN_STYLE_GUIDE.md` - Naming, formatting, documentation (11.5KB)
- `MODULE_ORGANIZATION.md` - Directory structure, namespaces (12KB)
- `QUALITY_METRICS.md` - Coverage, lint, performance targets (8KB)
- `TESTING_STANDARDS.md` - Test requirements (11.8KB)
- `TACTIC_DEVELOPMENT.md` - Custom tactic patterns (10.7KB)
- `README.md` - Empty placeholder

### 1.4 CLAUDE.md Current Documentation

CLAUDE.md Section 3 (Project Structure) documents:
- `Archive/` as "Pedagogical examples" at root level
- `Counterexamples/` as "Invalidity demonstrations" at root level
- `docs/` as "User documentation"
- `src/docs/` as "Developer standards"

CLAUDE.md Section 4 (Documentation Index) separates:
- **Developer Standards (src/docs/)**: Style guide, module organization, testing, tactics, quality metrics
- **User Documentation (docs/)**: Architecture, tutorial, examples, contributing, integration, versioning

## 2. Lean 4 Naming Conventions Research

### 2.1 File and Directory Naming

**Key Finding**: Lean 4 uses **PascalCase (UpperCamelCase)** for files and directories.

#### Sources:
- [Mathlib Naming Conventions](https://leanprover-community.github.io/contribute/naming.html): ".lean files in mathlib should generally be named in UpperCamelCase (PascalCase)"
- [Lean 4 Issue #30](https://github.com/leanprover/lean4/issues/30): Confirms Lean 4 uses PascalCase file naming
- Exception: Very rare cases for specifically lower-cased objects (e.g., `lp.lean` for ℓₚ space)

### 2.2 Module Naming

**Convention**: Modules are named using CamelCase (e.g., `MyModule.lean`)

#### Rationale:
- File/directory names correspond directly to module names in Lean 4's import system
- `import Archive.ModalProofs` maps to `Archive/ModalProofs.lean`
- Case-sensitivity matters for imports

### 2.3 Declaration Naming (Not Directory Names)

For declarations within code (not relevant to directory naming):
- **Theorems/proofs**: `snake_case` (e.g., `soundness`, `weak_completeness`)
- **Types/structures/classes**: `UpperCamelCase` (e.g., `TaskFrame`, `Formula`)
- **Functions**: `snake_case` (e.g., `truth_at`)

## 3. Mathlib4 Organization Patterns

### 3.1 Archive Directory in Mathlib4

**Research Finding**: Mathlib4 has a dedicated `Archive/` directory at the root level.

#### Structure:
```
Archive/
├── Examples/               # Example formalizations
├── Imo/                   # International Mathematical Olympiad problems
├── MiuLanguage/           # Miu language formalization
├── OxfordInvariants/      # Oxford summer program work
├── Wiedijk100Theorems/    # Collection of 100 theorems
├── Arithcc.lean
├── Hairer.lean
├── Kuratowski.lean
├── Sensitivity.lean
└── ZagierTwoSquares.lean
```

#### Purpose (from Mathlib4 README):
> "An archive for formalizations which don't have a good place in mathlib, probably because there is (almost) no math depending on these results."

**Key Insight**: Archive serves as a repository for pedagogical examples and demonstrations that don't belong in the main library.

### 3.2 Counterexamples Directory in Mathlib4

**Research Finding**: Mathlib4 has a dedicated `Counterexamples/` directory at the root level with 28 files.

#### Organization Pattern:
- Each file named descriptively in PascalCase
- Examples: `SorgenfreyLine.lean`, `TopologistsSineCurve.lean`, `IrrationalPowerOfIrrational.lean`
- Covers topics in algebra, topology, number theory

**Key Insight**: Counterexamples are organized as a flat directory with descriptive file names, not nested subdirectories.

### 3.3 Lakefile Configuration

Mathlib4's `lakefile.lean` defines separate libraries:
- `Mathlib` (main)
- `Archive`
- `Counterexamples`
- `MathlibTest`

**Pattern**: Examples and counterexamples are separate libraries from the main library.

## 4. Examples Organization Research

### 4.1 Current State

Logos currently has:
- `Archive/` with plans for `ModalProofs.lean`, `TemporalProofs.lean`, `BimodalProofs.lean`
- `docs/EXAMPLES.md` (10.4KB) with usage examples in markdown

### 4.2 Archive vs Examples Naming

**Research Finding**: Multiple patterns exist in Lean/proof assistant ecosystem:

1. **Mathlib4 Pattern**: Uses `Archive/` for historical/pedagogical examples
2. **General Programming Pattern**: `Examples/` is more common in software projects
3. **Proof Assistant Pattern**: Isabelle's Archive of Formal Proofs uses "Archive"

### 4.3 Recommendation: Keep Archive

**Reasoning**:
1. **Alignment with Mathlib4**: Logos already follows Mathlib4's Archive pattern
2. **Semantic distinction**: "Archive" suggests curated, maintained examples vs. throwaway demos
3. **Existing documentation**: CLAUDE.md already documents Archive as pedagogical examples
4. **Lake configuration**: Already defined as a separate library

**Consolidation Opportunity**: The content in `docs/EXAMPLES.md` could be:
- Moved to literate programming examples in `Archive/`
- Or kept as complementary quickstart examples in docs

## 5. Documentation Organization Analysis

### 5.1 The Dual-Docs Problem

**Current State**:
- `docs/` - User-facing documentation (architecture, tutorial, examples, contributing)
- `src/docs/` - Developer-facing standards (style guide, testing, quality metrics)

### 5.2 Industry Patterns

**Common Patterns in Software Projects**:
1. **Single docs/ directory**: All documentation in one place with subdirectories
2. **Root-level docs/**: User docs at `docs/`, developer docs at `docs/dev/` or `docs/developer/`
3. **src/ for code only**: `src/` typically contains source code, not documentation

### 5.3 Lean 4 Documentation Practices

**Research Finding**: Lean 4 projects typically use:
- `docs/` directory for user documentation
- In-code documentation with docstrings
- Doc generation tools (doc-gen4) for API documentation

**Example from Lean 4 Development Guide**:
- Documentation is generated from in-code docstrings
- Mathlib uses `docs/references.bib` for citations
- Module documentation uses `/-! ... -/` sectioning comments

### 5.4 The src/ Directory Issue

**Current Problem**: Logos has `src/docs/` containing developer standards, but:
- No other code in `src/`
- `src/` typically contains source code in software projects
- Creates confusion: "Is this source code or documentation?"

**Research Finding**: In Lean 4 projects:
- Source code goes in `ProjectName/` directory (e.g., `Logos/`)
- `src/` is not a standard Lean 4 convention for library code
- Lake expects code in directories matching library names

## 6. Proposed Refactoring Recommendations

### 6.1 Directory Naming: Standardize to PascalCase

**Recommendation**: Rename lowercase directories to PascalCase.

| Current | Proposed | Rationale |
|---------|----------|-----------|
| `docs/` | `Docs/` | Align with Lean 4 PascalCase convention |
| `src/docs/` | `Docs/Development/` | Remove `src/`, nest developer docs under `Docs/` |

**Alternative**: Keep `docs/` lowercase if treating as project metadata (like `.github/`, `.gitignore`)

**Pro**: Many Lean 4 projects keep metadata directories lowercase
**Con**: Creates inconsistency with `Archive/`, `Counterexamples/`

### 6.2 Documentation Consolidation

**Recommendation**: Consolidate documentation under single `Docs/` directory.

```
Docs/
├── ARCHITECTURE.md          # User: System design
├── TUTORIAL.md              # User: Getting started
├── EXAMPLES.md              # User: Usage examples
├── CONTRIBUTING.md          # User: How to contribute
├── INTEGRATION.md           # User: Model-Checker integration
├── VERSIONING.md            # User: Versioning policy
└── Development/             # Developer standards
    ├── LEAN_STYLE_GUIDE.md
    ├── MODULE_ORGANIZATION.md
    ├── TESTING_STANDARDS.md
    ├── TACTIC_DEVELOPMENT.md
    └── QUALITY_METRICS.md
```

**Benefits**:
- Single source of truth for all documentation
- Clear separation: root level for users, `Development/` for contributors
- Eliminates confusion about `src/` directory
- Aligns with common software project patterns

### 6.3 Alternative: Metadata Convention

**Alternative Recommendation**: Keep documentation lowercase as project metadata.

```
docs/                        # User documentation (lowercase = metadata)
├── ARCHITECTURE.md
├── TUTORIAL.md
├── EXAMPLES.md
├── CONTRIBUTING.md
├── INTEGRATION.md
├── VERSIONING.md
└── development/             # Developer standards
    ├── LEAN_STYLE_GUIDE.md
    ├── MODULE_ORGANIZATION.md
    ├── TESTING_STANDARDS.md
    ├── TACTIC_DEVELOPMENT.md
    └── QUALITY_METRICS.md
```

**Rationale**:
- Treats documentation as project metadata (like `.github/`, `.gitignore`)
- Common in open-source projects (e.g., GitHub renders `docs/` specially)
- Less disruptive change
- Distinguishes non-Lean files from Lean modules

**Trade-off**: Creates naming inconsistency with `Archive/`, `Counterexamples/`

### 6.4 Examples Organization

**Recommendation**: Keep `Archive/` and develop it according to plan.

```
Archive/
├── Archive.lean             # Root module
├── Modal/                   # S5 modal logic examples
│   ├── Basic.lean
│   ├── ModalK.lean
│   └── Theorems.lean
├── Temporal/                # Temporal logic examples
│   ├── Basic.lean
│   ├── Duality.lean
│   └── Theorems.lean
└── Bimodal/                 # Combined modal-temporal
    ├── Perpetuity.lean
    └── Interactions.lean
```

**Benefits**:
- Aligns with Mathlib4 Archive pattern
- Allows for organized growth with subdirectories
- Clear separation from main library code
- Already configured in lakefile

### 6.5 Counterexamples Organization

**Recommendation**: Keep `Counterexamples/` and follow Mathlib4 flat pattern.

```
Counterexamples/
├── Counterexamples.lean     # Root module
├── InvalidFormulas.lean     # Formulas that are not TM-theorems
├── AxiomIndependence.lean   # Axioms independent from others
├── TemporalEdgeCases.lean   # Temporal operator subtleties
└── TaskSemantics.lean       # Task relation edge cases
```

**Benefits**:
- Follows proven Mathlib4 pattern
- Flat structure keeps files discoverable
- Descriptive PascalCase names
- Educational value for understanding logic boundaries

## 7. Impact Analysis

### 7.1 Breaking Changes

**Import Statements**:
- All imports from `Archive.*`, `Counterexamples.*` remain unchanged (already PascalCase)
- No breaking changes to Lean code imports

**Documentation References**:
- CLAUDE.md references to `src/docs/` need updating
- README.md documentation links need updating
- Any relative links in markdown files need updating

**Build Configuration**:
- No changes to `lakefile.toml` (libraries already correctly named)
- No changes to `lean-toolchain`

### 7.2 Git History

**Strategy**: Use `git mv` to preserve file history
```bash
git mv src/docs/ docs/development/
```

### 7.3 CI/CD Impact

**Consideration**: Check if `.github/workflows/ci.yml` references:
- Documentation paths
- Test paths
- Build artifacts

## 8. Comparison of Approaches

### 8.1 Option A: Full PascalCase Consistency

```
Logos/
├── Archive/
├── Counterexamples/
├── Docs/
│   └── Development/
├── Logos/
└── LogosTest/
```

**Pros**:
- Complete consistency with Lean 4 conventions
- All libraries/examples in PascalCase
- Clear that these are Lean-related directories

**Cons**:
- `Docs/` looks unusual (most projects use lowercase)
- May confuse contributors familiar with `docs/` convention

### 8.2 Option B: Metadata Convention (RECOMMENDED)

```
Logos/
├── Archive/                 # Lean library (PascalCase)
├── Counterexamples/         # Lean library (PascalCase)
├── docs/                    # Project metadata (lowercase)
│   └── development/
├── Logos/            # Lean library (PascalCase)
└── LogosTest/        # Lean library (PascalCase)
```

**Pros**:
- Distinguishes Lean code/examples from project metadata
- Familiar to open-source contributors
- Minimal disruption
- GitHub/GitLab/etc. recognize `docs/` directory

**Cons**:
- Minor inconsistency in naming convention

### 8.3 Option C: Minimal Change

```
Logos/
├── Archive/
├── Counterexamples/
├── docs/                    # User docs (keep as-is)
│   └── developer/          # Rename from src/docs/
├── Logos/
└── LogosTest/
```

**Pros**:
- Smallest change
- Preserves familiar `docs/` location

**Cons**:
- Doesn't fully resolve naming inconsistency
- Still have lowercase `docs/` vs PascalCase libraries

## 9. Recommendations Summary

### 9.1 Primary Recommendation (Option B)

**Directory Structure**:
```
Logos/
├── Archive/                          # Pedagogical examples (PascalCase)
│   ├── Archive.lean
│   ├── Modal/
│   ├── Temporal/
│   └── Bimodal/
├── Counterexamples/                  # Invalidity demonstrations (PascalCase)
│   ├── Counterexamples.lean
│   ├── InvalidFormulas.lean
│   └── [flat list of counterexamples]
├── docs/                             # Project documentation (lowercase metadata)
│   ├── ARCHITECTURE.md
│   ├── TUTORIAL.md
│   ├── EXAMPLES.md
│   ├── CONTRIBUTING.md
│   ├── INTEGRATION.md
│   ├── VERSIONING.md
│   └── development/                  # Developer standards
│       ├── LEAN_STYLE_GUIDE.md
│       ├── MODULE_ORGANIZATION.md
│       ├── TESTING_STANDARDS.md
│       ├── TACTIC_DEVELOPMENT.md
│       └── QUALITY_METRICS.md
├── Logos/                     # Main library (PascalCase)
└── LogosTest/                 # Test suite (PascalCase)
```

**Rationale**:
1. **Lean libraries in PascalCase**: `Archive/`, `Counterexamples/`, `Logos/`, `LogosTest/`
2. **Project metadata in lowercase**: `docs/` treated as non-Lean project documentation
3. **Clear organization**: User docs at `docs/`, developer docs at `docs/development/`
4. **Familiar convention**: Open-source contributors recognize `docs/` directory
5. **Minimal disruption**: Only moves `src/docs/` to `docs/development/`

### 9.2 Implementation Steps

1. **Create new structure**:
   ```bash
   mkdir -p docs/development
   ```

2. **Move developer standards**:
   ```bash
   git mv src/docs/LEAN_STYLE_GUIDE.md docs/development/
   git mv src/docs/MODULE_ORGANIZATION.md docs/development/
   git mv src/docs/TESTING_STANDARDS.md docs/development/
   git mv src/docs/TACTIC_DEVELOPMENT.md docs/development/
   git mv src/docs/QUALITY_METRICS.md docs/development/
   ```

3. **Remove empty directories**:
   ```bash
   rm -rf src/docs/README.md
   rmdir src/docs src
   ```

4. **Update CLAUDE.md**:
   - Section 3: Update path from `src/docs/` to `docs/development/`
   - Section 4: Update documentation index paths

5. **Update README.md**:
   - Update any links to developer documentation

6. **Update documentation files**:
   - Search for relative links referencing `src/docs/` or `../src/docs/`
   - Update to `development/` or `../development/`

7. **Verify build**:
   ```bash
   lake clean
   lake build
   ```

### 9.3 Future Enhancements

1. **Develop Archive/** with planned examples:
   - `Archive/Modal/` subdirectory for S5 modal examples
   - `Archive/Temporal/` subdirectory for temporal examples
   - `Archive/Bimodal/` subdirectory for combined examples

2. **Populate Counterexamples/** with:
   - Invalid formula constructions
   - Axiom independence results
   - Edge cases in task semantics

3. **Consider docs/development/ → docs/dev/**:
   - Shorter path: `docs/dev/` instead of `docs/development/`
   - Common abbreviation in software projects

## 10. References and Sources

### Lean 4 Naming Conventions
- [Mathlib Naming Conventions](https://leanprover-community.github.io/contribute/naming.html)
- [Lean Community: Naming Convention Template](https://github.com/leanprover-community/leanprover-community.github.io/blob/lean4/templates/contribute/naming.md)
- [Lean 4 Issue #30: Inconsistent handling of capitalization in module names](https://github.com/leanprover/lean4/issues/30)

### Mathlib4 Organization
- [Mathlib4 GitHub Repository](https://github.com/leanprover-community/mathlib4)
- [Mathlib4 Archive Directory](https://github.com/leanprover-community/mathlib4/tree/master/Archive/Imo)
- [Mathlib4 Counterexamples Directory](https://github.com/leanprover-community/mathlib4/tree/master/Counterexamples)
- [Counterexamples.SorgenfreyLine Documentation](https://leanprover-community.github.io/mathlib4_docs/Counterexamples/SorgenfreyLine.html)

### Lean 4 Project Structure
- [Lean Community: Lean Projects](https://leanprover-community.github.io/install/project.html)
- [A Basic Lean 4 Project Template by Limperg](https://limperg.de/posts/2021-05-31-lean4-project.html)
- [Zulip Chat Archive: Required Project Structure?](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/Required.20Project.20Structure.3F.html)
- [Functional Programming in Lean: Starting a Project](https://leanprover.github.io/functional_programming_in_lean/hello-world/starting-a-project.html)

### Documentation Practices
- [Lean 4 Development Guide](https://docs.lean-lang.org/lean4/doc/dev/index.html)
- [Lean Community: Documentation Style](https://leanprover-community.github.io/contribute/doc.html)
- [doc-gen4 Documentation Generator](https://github.com/leanprover/doc-gen4)

### Proof Assistant Patterns
- [Archive of Formal Proofs (Isabelle)](https://www.isa-afp.org/)
- [The Lean Mathematical Library Paper (arXiv:1910.09336)](https://arxiv.org/pdf/1910.09336)
- [Quanta Magazine: Building the Mathematical Library of the Future](https://www.quantamagazine.org/building-the-mathematical-library-of-the-future-20201001/)

## 11. Conclusion

The Logos project currently has a well-structured codebase that largely follows Lean 4 conventions. The primary issues are:

1. **src/docs/ location**: Developer standards are in an unusual location (`src/docs/`) that doesn't align with typical project structure
2. **Documentation consolidation**: User and developer documentation should be unified under a single `docs/` directory
3. **Naming consistency**: The project uses a mix of PascalCase (for Lean libraries) and lowercase (for project metadata)

**Recommended approach**: Adopt Option B (Metadata Convention), which:
- Moves developer standards from `src/docs/` to `docs/development/`
- Keeps `docs/` lowercase as project metadata (like `.github/`)
- Maintains PascalCase for all Lean libraries (`Archive/`, `Counterexamples/`, `Logos/`, `LogosTest/`)
- Provides clear distinction between Lean code and project documentation
- Minimizes disruption while improving organization

This approach balances Lean 4 conventions, open-source familiarity, and practical maintainability.

## Implementation Status

- **Status**: Planning Complete
- **Plan**: [001-file-structure-examples-docs-refactor-plan.md](../plans/001-file-structure-examples-docs-refactor-plan.md)
- **Implementation**: Not started
- **Date**: 2025-12-01

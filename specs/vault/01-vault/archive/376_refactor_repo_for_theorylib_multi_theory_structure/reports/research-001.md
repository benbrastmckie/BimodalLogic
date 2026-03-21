# Research Report: Task #376

**Task**: Refactor repo for TheoryLib multi-theory structure
**Date**: 2026-01-11
**Focus**: Research best organization practices for multi-theory Lean 4 projects online

## Summary

This research investigates best practices for organizing a Lean 4 project with multiple theories (Bimodal, Logos, and future theories) that can share common resources while remaining independently buildable. Lake's multi-library and local path dependency features provide the foundation for a clean TheoryLib structure.

## Findings

### 1. Lake Multi-Library Configuration

Lake supports defining multiple `lean_lib` targets within a single package. Each library is configured independently:

**TOML Format:**
```toml
[[lean_lib]]
name = "CoreLib"
roots = ["CoreLib"]

[[lean_lib]]
name = "TheoryA"
roots = ["TheoryA"]
needs = ["CoreLib"]
```

**Lean Format:**
```lean
lean_lib CoreLib

lean_lib TheoryA where
  needs := #[`CoreLib]
```

Key configuration options:
- `roots`: Module hierarchy entry points
- `globs`: Which modules to build (e.g., `Glob.submodules` for recursive)
- `srcDir`: Custom source directory
- `needs`: Prerequisite library targets (for inter-library dependencies)

**Source**: [Lake Documentation](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/)

### 2. Local Path Dependencies for Subprojects

For monorepo setups, Lake supports local path dependencies:

```lean
require «package-name» from "path/to/package"
```

```toml
[[require]]
name = "package-name"
path = "path/to/package"
```

Paths are relative to the requiring package's directory. This enables:
- Each theory to have its own `lakefile.lean` if needed
- A root project that aggregates all theories
- Individual theories can be built/tested independently

**Source**: [GitHub - Lean4 Lake README](https://github.com/leanprover/lean4/blob/master/src/lake/README.md)

### 3. Mathlib4 Multi-Library Pattern

Mathlib4 demonstrates a sophisticated approach:

**Multiple Library Targets:**
- `Mathlib` - Primary library with full linting
- `MathlibTest` - Test library with restricted globs
- `Archive`, `Counterexamples` - Supporting libraries
- `docs` - Documentation-only target

**Configuration Abstraction:**
```lean
abbrev mathlibLeanOptions := ...
abbrev mathlibOnlyLinters := ...

lean_lib Mathlib where
  leanOptions := mathlibLeanOptions
```

This pattern enables consistent configuration across libraries while allowing selective overrides.

**Source**: [Mathlib4 lakefile.lean](https://github.com/leanprover-community/mathlib4/blob/master/lakefile.lean)

### 4. Foundation (lean4-logic) Project Structure

The Foundation project for formalizing mathematical logic organizes multiple logical systems under a single namespace:

```
Foundation/
  Propositional/      # Propositional logic
  FirstOrder/         # First-order logic
  Modal/              # Modal logic
  ProvabilityLogic/   # Provability logic
  InterpretabilityLogic/
  Logic/              # Shared fundamental tools
  Meta/               # Proof automation utilities
```

Key observations:
- Shared utilities in `Logic/` and `Meta/` directories
- Each logical system has its own subdirectory
- Single lakefile builds all components
- Comprehensive test coverage

**Source**: [Foundation GitHub](https://github.com/iehality/lean4-logic)

### 5. Current ProofChecker Structure

Current layout:
```
ProofChecker/
  lakefile.lean       # Defines: Logos, Bimodal, LogosTest, BimodalTest
  Logos.lean          # Re-exports Bimodal
  Bimodal.lean        # Main entry for Bimodal library
  Logos/              # Layered logic system (Layer0, Layer1, etc.)
  Bimodal/            # TM logic implementation
  LogosTest/          # Tests for Logos
  BimodalTest/        # Tests for Bimodal
  docs/      # Project documentation
```

Current lakefile already defines multiple `lean_lib` targets with shared options:
```lean
lean_lib Logos where
  leanOptions := #[...]

lean_lib Bimodal where
  leanOptions := #[...]
```

### 6. Recommended Directory Structures

**Option A: Single Package, Multiple Libraries**
Best for tightly coupled theories that share dependencies.

```
ProofChecker/
  lakefile.lean
  TheoryLib/
    Shared/           # Common utilities, imports
    Bimodal/          # TM logic
    Logos/            # Layered modal logic
    Future/           # Future theories
  TheoryLibTest/
    Bimodal/
    Logos/
```

**Option B: Monorepo with Local Path Dependencies**
Best for loosely coupled theories with different dependency requirements.

```
ProofChecker/
  lakefile.lean       # Root project requiring subprojects
  Shared/             # Common utilities (own package)
    lakefile.lean
  Theories/
    Bimodal/
      lakefile.lean   # require Shared from "../../Shared"
    Logos/
      lakefile.lean
```

**Option C: Hybrid (Recommended)**
Single package with organized directories, but structured for future extraction.

```
ProofChecker/
  lakefile.lean       # Multiple lean_lib targets
  Shared/             # Common definitions (lean_lib Shared)
    Core/             # Core types
    Tactics/          # Shared tactics
  Theories/
    Bimodal/          # lean_lib Bimodal where needs := #[`Shared]
    Logos/            # lean_lib Logos where needs := #[`Shared, `Bimodal]
  Tests/
    Bimodal/          # lean_lib BimodalTest
    Logos/
```

## Recommendations

1. **Use Option C (Hybrid Approach)**: Start with a single `lakefile.lean` defining multiple `lean_lib` targets. This keeps configuration simple while organizing code for future extraction.

2. **Create Shared Library**: Extract common utilities (tactics, core definitions, shared types) into a `Shared` or `Core` library that other theories can depend on via `needs`.

3. **Use `needs` for Inter-Library Dependencies**: Configure `needs = ["Shared"]` for each theory library to establish clear dependency ordering.

4. **Abstract Common Configuration**: Following Mathlib's pattern, define shared options:
   ```lean
   abbrev theoryLibLeanOptions := #[
     ⟨`pp.unicode.fun, true⟩,
     ⟨`autoImplicit, false⟩
   ]
   ```

5. **Organize Tests Parallel to Source**: Keep test libraries mirroring source structure:
   ```
   Theories/Bimodal/Syntax/Formula.lean
   Tests/Bimodal/Syntax/FormulaTest.lean
   ```

6. **Plan for Extraction**: Structure directories and namespaces so theories can be extracted to separate packages later if needed.

## References

- [Lake Official Documentation](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Lake/)
- [Lake's package vs lean_lib vs lean_exe](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/Lake's.20package.20vs.20lean_lib.20vs.20lean_exe.html)
- [Mathlib4 lakefile.lean](https://github.com/leanprover-community/mathlib4/blob/master/lakefile.lean)
- [Foundation/lean4-logic Project](https://github.com/iehality/lean4-logic)
- [Lean 4 Project Structure Requirements](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/Required.20Project.20Structure.3F.html)
- [Lean Projects Guide](https://leanprover-community.github.io/install/project.html)

## Next Steps

1. Design the specific TheoryLib directory structure based on Option C
2. Identify what should be extracted to the Shared library
3. Plan migration of existing Bimodal/ and Logos/ directories
4. Update lakefile.lean with new library structure
5. Update import paths across all Lean files
6. Ensure tests continue to pass after migration

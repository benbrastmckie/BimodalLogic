# Directory README Standard - LEAN 4 Projects

**Last Updated**: 2025-12-02
**Applies To**: LEAN 4 project directories (not .claude/ system)
**Complements**: [LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md) (code-level documentation)

## 1. Purpose and Scope

This document establishes standards for directory-level README files in LEAN 4 projects. These READMEs serve as **navigation guides** and **organizational documentation**, complementing but not duplicating the technical documentation provided by `.lean` module files and doc-gen4.

**Key Principle**: Directory READMEs are **lightweight** and **navigation-focused**. They answer "Where do I find X?" and "How do I use this directory?" without duplicating the "What does X do?" already covered by LEAN docstrings and module documentation.

### Scope

**In Scope (Covered by This Standard)**:
- LEAN source directories (`Logos/`, `Logos/Syntax/`, etc.)
- LEAN test directories (`LogosTest/`, `LogosTest/Syntax/`, etc.)
- LEAN example/archive directories (`Archive/`, `Archive/Examples/`, etc.)
- Documentation organization directories (`Documentation/`, `Documentation/UserGuide/`, etc.)

**Out of Scope (Covered Elsewhere)**:
- `.opencode/` system directories (see [documentation-standards.md](../../../.opencode/context/core/standards/documentation-standards.md))
- LEAN code documentation (see [LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md))
- API documentation (handled by doc-gen4 and `.lean` module files)

### Integration with Existing Standards

This standard **extends** and **complements**:
- **.opencode/context/core/standards/documentation-standards.md**: Adapted patterns for LEAN 4 projects
- **LEAN_STYLE_GUIDE.md**: Code-level documentation conventions
- **TESTING_STANDARDS.md**: Test documentation requirements
- **MODULE_ORGANIZATION.md**: Directory structure patterns

## 2. When README Required

### Classification Rules

**✓ README Required**:
1. **Top-level LEAN source directory** (`Logos/`): Module organization overview
2. **Test directory with 3+ subdirectories** (`LogosTest/`): Test organization and running instructions
3. **Example/Archive directory** (`Archive/`): Learning paths and pedagogical guidance
4. **Multi-subdirectory documentation root** (`Documentation/`): Documentation navigation

**✗ README Not Required**:
1. **Single-module directories** with excellent `.lean` module documentation
2. **Subdirectories** when parent README provides sufficient navigation
3. **Build/output directories** (`.lake/`, `build/`)
4. **Directories with <3 files** that are self-explanatory

### Decision Tree

```
Does directory contain 3+ subdirectories? → YES → README required
Does directory contain example/pedagogical code? → YES → README required (Template F)
Is directory a test suite root? → YES → README required (Template E)
Is directory a documentation collection? → YES → README required (Template G)
Is directory a top-level source module? → MAYBE → README optional (Template D, lightweight)
Otherwise → NO README needed (rely on .lean module documentation)
```

## 3. Template D: LEAN Source Directory (Lightweight)

**Use Case**: Top-level source directory (`Logos/`) or major submodule with multiple components

**Structure**:
```markdown
# [Directory Name]

Brief purpose statement (1-2 sentences)

## Submodules

List of subdirectories with one-line descriptions:
- **Syntax/**: Formula types and contexts
- **ProofSystem/**: Axioms and inference rules
- **Semantics/**: Task frame semantics

## Quick Reference

Where to find specific functionality:
- Formulas: `Syntax/Formula.lean`
- Axioms: `ProofSystem/Axioms.lean`
- Models: `Semantics/TaskModel.lean`

## Building and Type-Checking

```bash
# Build entire module
lake build

# Type-check specific file
lake env lean Logos/Syntax/Formula.lean
```

## API Documentation

For detailed API documentation, see:
- Module overview: [Logos.lean](../Logos.lean)
- Generated docs: Run `lake build :docs`
- Architecture guide: [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md)

## Related Documentation

- [LEAN Style Guide](../Documentation/Development/LEAN_STYLE_GUIDE.md)
- [Module Organization](../Documentation/Development/MODULE_ORGANIZATION.md)
```

**Notes**:
- Keep this README **very lightweight** (40-70 lines)
- Focus on **navigation** and **quick reference**
- **Do not duplicate** docstrings from `.lean` files
- Optional: Can be omitted if `.lean` module file is comprehensive

## 4. Template E: LEAN Test Directory

**Use Case**: Test suite directory with multiple test subdirectories

**Structure**:
```markdown
# [Test Directory Name]

Comprehensive test suite for [ProjectName], organized by module.

## Test Organization

Tests are organized by module under test:

- **Syntax/**: Formula construction, context tests
- **ProofSystem/**: Axiom schema and inference rule tests
- **Semantics/**: Task frame, model, validity tests
- **Integration/**: Cross-module integration tests
- **Metalogic/**: Soundness and completeness property tests

## Running Tests

### Run All Tests
```bash
lake test
```

### Run Specific Module Tests
```bash
# Test specific module
lake test LogosTest.Syntax
lake test LogosTest.ProofSystem

# Test specific file
lake env lean LogosTest/Syntax/FormulaTest.lean
```

### Interpreting Output
- ✓ Passing tests show green checkmarks
- ✗ Failing tests show error messages with line numbers
- Test summary includes pass/fail count

## Adding New Tests

### File Placement
- Unit tests: Place in module-specific subdirectory (`Syntax/`, `ProofSystem/`, etc.)
- Integration tests: Place in `Integration/`
- Property-based tests: Place in appropriate module or `Metalogic/`

### Naming Conventions
- **Files**: `<Module>Test.lean` (e.g., `FormulaTest.lean`)
- **Tests**: `test_<feature>_<expected_behavior>` (e.g., `test_imp_reflexivity`)

### Test Categories
1. **Unit Tests**: Test individual functions/definitions in isolation
2. **Integration Tests**: Test interactions between modules
3. **Property-Based Tests**: Test general properties (soundness, validity)
4. **Regression Tests**: Test fixed bugs to prevent recurrence

## Coverage Requirements

See [TESTING_STANDARDS.md](../Documentation/Development/TESTING_STANDARDS.md) for:
- Coverage targets (overall ≥85%, Metalogic ≥90%)
- Test quality standards
- Performance benchmarks

## Related Documentation

- [Testing Standards](../Documentation/Development/TESTING_STANDARDS.md)
- [Code Standards](../../.claude/docs/reference/standards/code-standards.md)
- [Module Organization](../Documentation/Development/MODULE_ORGANIZATION.md)
```

**Notes**:
- This README is **more substantial** (80-120 lines)
- Focus on **how to run tests** and **where to add new tests**
- Link to TESTING_STANDARDS.md for detailed requirements

## 5. Template F: LEAN Example Directory (Pedagogical)

**Use Case**: Archive or example directory with pedagogical code

**Structure**:
```markdown
# [Archive/Example Directory Name]

Pedagogical examples demonstrating [library/logic name], designed for learning and reference.

## Purpose

These examples illustrate:
- Key concepts in [domain]
- Idiomatic proof patterns
- Practical usage of the library

## Example Categories

### [Category 1]
- **[File1.lean]**: [Brief description]
- **[File2.lean]**: [Brief description]

### [Category 2]
- **[File3.lean]**: [Brief description]

## Learning Path

For newcomers, we recommend this progression:

1. **Start here**: [File for beginners] - Basic concepts and simple proofs
2. **Next**: [Intermediate file] - More complex reasoning
3. **Advanced**: [Advanced file] - Full demonstrations

## How to Run Examples

### In VS Code
1. Open example file in VS Code with lean4 extension
2. Use `Ctrl+Shift+Enter` to execute entire file
3. Hover over definitions to see types and documentation

### In Command Line
```bash
# Type-check an example
lake env lean Archive/BimodalProofs.lean

# Run interactive mode
lake env lean --run Archive/BimodalProofs.lean
```

### Importing Examples
```lean
-- Import specific example module
import Archive.BimodalProofs

-- Import entire archive
import Archive
```

## Contributing Examples

New examples should:
- Have clear docstrings explaining the concept
- Include step-by-step proof comments
- Follow [LEAN_STYLE_GUIDE.md](../Documentation/Development/LEAN_STYLE_GUIDE.md)
- Be accessible to learners (avoid overly complex proofs)

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution workflow.

## Related Documentation

- [Tutorial](../Documentation/UserGuide/TUTORIAL.md) - Getting started guide
- [Examples](../Documentation/UserGuide/EXAMPLES.md) - Usage examples
- [Architecture](../Documentation/UserGuide/ARCHITECTURE.md) - System design
```

**Notes**:
- Emphasize **learning paths** and **pedagogical value**
- Provide clear **usage instructions** (VS Code and CLI)
- Keep tone **welcoming** and **educational**

## 6. Template G: Documentation Directory

**Use Case**: Multi-subdirectory documentation collection

**Structure**:
```markdown
# [Documentation Directory Name]

Comprehensive documentation hub for [ProjectName].

## Documentation Organization

Documentation is organized into four categories:

### UserGuide/
User-facing documentation for working with [project]:
- **ARCHITECTURE.md**: System design and logic specification
- **TUTORIAL.md**: Getting started guide
- **EXAMPLES.md**: Usage examples and patterns
- **INTEGRATION.md**: Integration with other tools

**Audience**: Users of the library, learners

### ProjectInfo/
Project status and tactic documentation:
- **IMPLEMENTATION_STATUS.md**: Module-by-module status tracking (includes Known Limitations section)
- **SORRY_REGISTRY.md**: Technical debt tracking
- **TACTIC_REGISTRY.md**: Custom tactic patterns

**Audience**: Contributors, maintainers

### Development/
Developer standards, conventions, and contribution workflow:
- **LEAN_STYLE_GUIDE.md**: Coding conventions
- **MODULE_ORGANIZATION.md**: Directory structure
- **TESTING_STANDARDS.md**: Test requirements
- **QUALITY_METRICS.md**: Quality targets
- **CONTRIBUTING.md**: Contribution guidelines
- **MAINTENANCE.md**: TODO management workflow
- **VERSIONING.md**: Semantic versioning policy

**Audience**: Developers, contributors

### Reference/
Reference materials:
- **OPERATORS.md**: Formal symbols reference

**Audience**: All users

## Quick Links

Most-referenced documents:
- [Getting Started](UserGuide/TUTORIAL.md)
- [Implementation Status](ProjectInfo/IMPLEMENTATION_STATUS.md)
- [Style Guide](Development/LEAN_STYLE_GUIDE.md)
- [Testing Standards](Development/TESTING_STANDARDS.md)

## Documentation Update Workflow

When updating documentation:

1. **User-facing changes**: Update relevant UserGuide/ files first
2. **Implementation changes**: Update ProjectInfo/IMPLEMENTATION_STATUS.md
3. **New limitations**: Document in ProjectInfo/IMPLEMENTATION_STATUS.md Known Limitations section
4. **Style changes**: Update Development/ standards files
5. **Cross-references**: Ensure all links remain valid

## Documentation Standards

All documentation files follow:
- 100-character line limit
- Markdown formatting conventions
- Formal symbol backtick standard (see [documentation-standards.md](../../.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard))

## Related Files

- [README.md](../../README.md) - Project overview
```

**Notes**:
- Emphasize **audience guidance** (who should read what)
- Provide **quick links** to most-used documents
- Include **documentation update workflow**

## 7. Relationship to doc-gen4

### Division of Labor

**doc-gen4 generates** (automatically from `.lean` files):
- API documentation (function signatures, types)
- Docstring content from LEAN code
- Module dependency graphs
- Cross-reference links between definitions

**Directory READMEs provide** (manual, curated):
- High-level organization overview
- Navigation guidance ("Where do I find X?")
- Usage instructions (how to run tests, examples)
- Learning paths (for pedagogical directories)
- Context and motivation (why things are organized this way)

### Best Practice: Avoid Duplication

**✗ Don't duplicate** in directory README:
```markdown
## Formula Type

The `Formula` inductive type represents well-formed formulas in TM logic:
- `atom`: Propositional variables
- `bot`: Bottom (false)
- `imp`: Implication
- `box`: Necessity operator (□)
- `past`: Past operator (H)
- `future`: Future operator (G)
```

**✓ Instead, provide navigation**:
```markdown
## Quick Reference

- **Formulas**: See `Formula` type in [Syntax/Formula.lean](Syntax/Formula.lean)
- **Axioms**: See `Axiom` inductive in [ProofSystem/Axioms.lean](ProofSystem/Axioms.lean)
```

The detailed documentation of `Formula` belongs in the docstring in `Formula.lean`, where doc-gen4 will process it.

## 8. Anti-patterns

### Anti-pattern 1: Over-Documentation

**Problem**: README duplicates docstrings from `.lean` files

**Example**:
```markdown
## Functions

### `truth_at`
Evaluates truth of a formula at a model, history, and time.

**Parameters**:
- `M : TaskModel W S T Γ`: The task model
- `φ : Formula`: The formula to evaluate
- `h : WorldHistory W S T`: The world history
- `t : T`: The time point

**Returns**: `Prop` - Truth value
```

**Why Bad**: This exact information should be in the docstring of `truth_at` in the `.lean` file.

**Fix**: Remove duplication. If you want to guide users, write:
```markdown
For truth evaluation details, see `truth_at` in [Semantics/Truth.lean](Semantics/Truth.lean).
```

### Anti-pattern 2: Stale Documentation

**Problem**: README describes files/structure that no longer exists

**Example**:
```markdown
- **Rules.lean**: Inference rules (MP, MK, TK, TD)
```
(when `Rules.lean` doesn't exist and rules are actually in `Derivation.lean`)

**Why Bad**: Misleads users, wastes time searching for non-existent files

**Fix**: Keep README synchronized with actual directory structure. When refactoring, update READMEs immediately.

### Anti-pattern 3: Missing README When Needed

**Problem**: Complex directory (e.g., test suite with 8 subdirectories) has no README

**Why Bad**: Users don't know how to navigate or use the directory

**Fix**: Follow classification rules (Section 2). If directory has 3+ subdirectories or pedagogical purpose, create README.

### Anti-pattern 4: README for Simple Directories

**Problem**: Every single subdirectory has a README, even 2-file directories

**Why Bad**: Maintenance burden, cognitive overload, duplication of obvious information

**Fix**: Only create READMEs where they add genuine navigation value. For simple directories, excellent `.lean` module documentation suffices.

## 9. Examples from Logos

### Good Example: Archive/README.md

Following Template F (Pedagogical), this README provides:
- Purpose statement: "Pedagogical examples for learning TM logic"
- Example categories: Modal, temporal, bimodal
- Learning path: Beginner → intermediate → advanced
- How to run examples: VS Code and CLI instructions
- Links to Tutorial and Examples documentation

**Why Good**: Navigation-focused, provides learning context, doesn't duplicate BimodalProofs.lean docstrings.

### Good Example: LogosTest/README.md

Following Template E (Test Directory), this README provides:
- Test organization by module
- Running tests: `lake test`, `lake test LogosTest.Syntax`
- Adding new tests: file placement and naming conventions
- Test categories: unit, integration, property-based
- Links to TESTING_STANDARDS.md for detailed requirements

**Why Good**: Practical instructions for running and adding tests, appropriate level of detail.

### Good Example: Documentation/README.md

Following Template G (Documentation Directory), this README provides:
- Organization into 4 subdirectories with audience guidance
- Quick links to most-referenced documents
- Documentation update workflow
- Clear navigation without duplicating document contents

**Why Good**: Excellent navigation aid, clarifies who should read what.

## 10. Maintenance Guidelines

### When to Update Directory READMEs

**Update README when**:
- Adding or removing subdirectories
- Renaming files referenced in README
- Changing test running commands
- Adding new test categories or conventions
- Reorganizing learning paths (for pedagogical directories)

**Don't update README for**:
- Changes to function implementations (that's `.lean` docstrings)
- Minor docstring updates in `.lean` files
- Addition of new functions (unless they change navigation significantly)

### Review Checklist

When reviewing directory README:

- [ ] Does README provide navigation value?
- [ ] Does README avoid duplicating `.lean` docstrings?
- [ ] Are all file references accurate and up-to-date?
- [ ] Are all links valid?
- [ ] Does README follow appropriate template (D, E, F, or G)?
- [ ] Is README lightweight (appropriate line count)?
- [ ] Does README help intended audience?

## 11. References

### Standards Referenced
- [documentation-standards.md](../../../.opencode/context/core/standards/documentation-standards.md) - OpenCode documentation standards
- [LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md) - Code-level documentation
- [TESTING_STANDARDS.md](TESTING_STANDARDS.md) - Test documentation requirements
- [MODULE_ORGANIZATION.md](MODULE_ORGANIZATION.md) - Directory structure patterns

### External References
- [mathlib4 documentation practices](https://github.com/leanprover-community/mathlib4/tree/master/Mathlib)
- [LEAN 4 documentation](https://lean-lang.org/documentation/)
- [doc-gen4](https://github.com/leanprover/doc-gen4) - LEAN API documentation generator

---

**Version**: 1.0.0
**Last Updated**: 2025-12-02
**Maintained By**: Logos project

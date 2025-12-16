# CLAUDE.md - ProofChecker Project Configuration

## 1. Project Overview

ProofChecker is a LEAN 4 implementation of an axiomatic proof system for the bimodal logic TM (Tense and Modality) with task semantics. It provides:

- **Bimodal Logic TM**: Combining S5 modal logic (metaphysical necessity/possibility) with linear temporal logic (past/future operators)
- **Task Semantics**: Possible worlds as functions from times to world states constrained by task relations
- **Layered Architecture**: Layer 0 (Core TM) with planned extensions for counterfactual, epistemic, and normative operators
- **Complete Metalogic**: Soundness and completeness proofs for the core system
- **Perpetuity Principles**: P1-P6 derived theorems connecting modal and temporal operators

## 2. Essential Commands

```bash
# Build the project
lake build

# Run tests
lake test

# Run linter
lake lint

# Clean build artifacts
lake clean

# Generate documentation
lake build :docs

# Type-check a specific file
lake env lean <path/to/file.lean>

# Interactive evaluation (in VS Code or lean --run)
#check <expression>
#eval <expression>
#reduce <expression>
```

## 3. Project Structure

```
ProofChecker/
├── ProofChecker.lean           # Library root (re-exports all public modules)
├── ProofChecker/               # Main source directory
│   ├── Syntax/                 # Formula types, parsing, DSL
│   │   ├── Formula.lean        # Core formula inductive type
│   │   ├── Context.lean        # Proof context (premise lists)
│   │   └── DSL.lean            # Domain-specific syntax
│   ├── ProofSystem/            # Axioms and inference rules
│   │   ├── Axioms.lean         # TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
│   │   ├── Rules.lean          # Inference rules (MP, MK, TK, TD)
│   │   └── Derivation.lean     # Derivability relation
│   ├── Semantics/              # Task frame semantics
│   │   ├── TaskFrame.lean      # Task frame structure
│   │   ├── WorldHistory.lean   # World history definition
│   │   ├── TaskModel.lean      # Model with valuation
│   │   ├── Truth.lean          # Truth evaluation
│   │   └── Validity.lean       # Validity and consequence
│   ├── Metalogic/              # Soundness and completeness
│   │   ├── Soundness.lean      # Soundness theorem
│   │   ├── Completeness.lean   # Completeness theorem (canonical model)
│   │   └── Decidability.lean   # Decision procedures
│   ├── Theorems/               # Key theorems
│   │   └── Perpetuity.lean     # P1-P6 perpetuity principles
│   └── Automation/             # Proof automation
│       ├── Tactics.lean        # Custom tactics (modal_k, temporal_k, etc.)
│       └── ProofSearch.lean    # Automated proof search
├── ProofCheckerTest/           # Test suite
│   ├── ProofCheckerTest.lean   # Test library root
│   ├── Syntax/                 # Tests for formula construction and parsing
│   ├── ProofSystem/            # Tests for axioms and inference rules
│   ├── Semantics/              # Tests for task semantics and validity
│   ├── Integration/            # Cross-module integration tests
│   └── Metalogic/              # Soundness/completeness tests
├── Archive/                    # Pedagogical examples
│   ├── Archive.lean            # Archive library root
│   ├── ModalProofs.lean        # S5 modal logic examples
│   ├── TemporalProofs.lean     # Temporal reasoning examples
│   └── BimodalProofs.lean      # Combined modal-temporal examples
├── Counterexamples/            # Invalidity demonstrations
│   └── Counterexamples.lean    # Counterexamples library root
├── docs/                       # User documentation
│   ├── ARCHITECTURE.md         # System design and TM logic specification
│   ├── TUTORIAL.md             # Getting started guide
│   ├── EXAMPLES.md             # Usage examples
│   ├── CONTRIBUTING.md         # Contribution guidelines
│   ├── INTEGRATION.md          # Model-Checker integration
│   ├── VERSIONING.md           # Versioning policy
│   └── development/            # Developer standards
│       ├── LEAN_STYLE_GUIDE.md     # Coding conventions
│       ├── MODULE_ORGANIZATION.md  # Directory structure
│       ├── TESTING_STANDARDS.md    # Test requirements
│       ├── TACTIC_DEVELOPMENT.md   # Custom tactic patterns
│       └── QUALITY_METRICS.md      # Quality targets
├── lakefile.toml               # LEAN 4 build configuration
├── lean-toolchain              # LEAN version pinning
├── .gitignore                  # Git exclusions
└── .github/workflows/ci.yml    # CI/CD pipeline
```

## 4. Documentation Index

### Developer Standards (docs/development/)
- [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md) - Naming, formatting, documentation
- [Module Organization](docs/development/MODULE_ORGANIZATION.md) - Directory structure, namespaces
- [Testing Standards](docs/development/TESTING_STANDARDS.md) - Test types, coverage requirements
- [Tactic Development](docs/development/TACTIC_DEVELOPMENT.md) - Custom tactic patterns
- [Quality Metrics](docs/development/QUALITY_METRICS.md) - Coverage, lint, performance targets

### User Documentation (docs/)
- [Architecture Guide](docs/ARCHITECTURE.md) - System design and TM logic specification
- [Tutorial](docs/TUTORIAL.md) - Getting started with ProofChecker
- [Examples](docs/EXAMPLES.md) - Modal, temporal, bimodal examples
- [Contributing](docs/CONTRIBUTING.md) - How to contribute
- [Integration](docs/INTEGRATION.md) - Model-Checker integration
- [Versioning](docs/VERSIONING.md) - Semantic versioning policy

## 5. Development Principles

### Test-Driven Development (TDD) - MANDATORY
1. **RED**: Write a failing test that describes expected behavior
2. **GREEN**: Write minimal code to make the test pass
3. **REFACTOR**: Improve code quality while keeping tests green

Every new theorem, definition, or tactic requires tests before implementation.

### Fail-Fast Philosophy
- Functions should fail immediately on invalid input rather than propagating errors
- Use `Option` for recoverable failures, explicit error handling for others
- No silent failures or implicit defaults for invalid states

### Documentation Required
- Every public `def`, `theorem`, `lemma`, `structure`, `inductive` requires a docstring
- Module docstrings (`/-! ... -/`) at the top of every file
- Examples in docstrings where helpful

### Lint Compliance
- Zero `#lint` warnings allowed
- All definitions must pass `docBlame` (documentation check)
- All theorems must pass `docBlameThm`

## 6. Key Packages

### Syntax Package
- `Formula`: Inductive type for TM formulas (atom, bot, imp, box, past, future)
- `Context`: Proof contexts (premise lists)
- DSL macros for readable formula construction

### ProofSystem Package
- `Axiom`: TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
- `Derivable`: Inductive derivability relation
- Inference rules: MP, MK (modal K), TK (temporal K), TD (temporal duality)

### Semantics Package
- `TaskFrame`: World states, times, task relation with nullity and compositionality
- `WorldHistory`: Functions from convex time sets to world states
- `TaskModel`: Task frame with valuation function
- `truth_at`: Truth evaluation at model-history-time triples

### Metalogic Package
- `soundness`: Γ ⊢ φ → Γ ⊨ φ
- `weak_completeness`: ⊨ φ → ⊢ φ
- `strong_completeness`: Γ ⊨ φ → Γ ⊢ φ
- Canonical model construction for completeness proof

### Theorems Package
- Perpetuity principles P1-P6 connecting modal and temporal operators:
  - P1: □φ → always φ (necessary implies always)
  - P2: sometimes φ → ◇φ (sometimes implies possible)
  - P3: □φ → □always φ (necessity of perpetuity)
  - P4: ◇sometimes φ → ◇φ (possibility of occurrence)
  - P5: ◇sometimes φ → always ◇φ (persistent possibility)
  - P6: sometimes □φ → □always φ (occurrent necessity is perpetual)

## 7. Testing Architecture

```
ProofCheckerTest/
├── ProofCheckerTest.lean       # Test library root
├── Syntax/                     # Unit tests for formula construction, parsing
│   └── FormulaTest.lean
├── ProofSystem/                # Unit tests for axiom application, rule correctness
│   ├── AxiomsTest.lean
│   └── RulesTest.lean
├── Semantics/                  # Unit tests for truth evaluation, validity
│   ├── TaskFrameTest.lean
│   └── ValidityTest.lean
├── Integration/                # Cross-module integration tests
│   ├── SoundnessTest.lean      # End-to-end soundness verification
│   └── CompletenessTest.lean   # Completeness with canonical model
└── Metalogic/                  # Property tests
    └── ConsistencyTest.lean    # TM-consistency preservation
```

### Test Naming Convention
- Files: `<Module>Test.lean` (e.g., `FormulaTest.lean`)
- Tests: `test_<feature>_<expected_behavior>` (e.g., `test_modal_t_valid`)

## 8. Quality Standards

### Coverage Targets
- Overall: ≥85%
- Metalogic/: ≥90% (soundness, completeness critical)
- Automation/: ≥80%
- Error handling: ≥75%

### Lint Requirements
- `#lint`: Zero warnings
- `docBlame`: 100% documented definitions
- `docBlameThm`: 100% documented theorems

### Performance Benchmarks
- Build time: <2 minutes
- Test execution: <30 seconds
- Proof search: <1 second per query
- Documentation generation: <1 minute

### Complexity Limits
- Function complexity: <50 lines
- Module size: <1000 lines
- Max nesting depth: 4 levels
- Proof tactic count: <20 tactics per proof

## 9. Common Tasks

### Add a New Axiom
1. Define axiom schema in `ProofSystem/Axioms.lean`
2. Add case to `Derivable` in `ProofSystem/Derivation.lean`
3. Prove validity lemma in `Metalogic/Soundness.lean`
4. Write tests in `ProofCheckerTest/ProofSystem/`
5. Document with examples

### Create a Custom Tactic
1. Define tactic in `Automation/Tactics.lean`
2. Write unit tests in `ProofCheckerTest/Automation/`
3. Add example usage to `Archive/`
4. Document in `docs/development/TACTIC_DEVELOPMENT.md`

### Add a New Theorem
1. Write failing test in appropriate `ProofCheckerTest/` directory
2. Prove theorem in `Theorems/` or relevant module
3. Add docstring with mathematical statement and proof sketch
4. Update documentation if theorem is significant

### Prove Soundness for New Axiom
1. Add validity lemma to `Metalogic/Soundness.lean`
2. Prove axiom valid in all task semantic models
3. Add case to main `soundness` theorem
4. Test with example formulas

## 10. Notes for Claude Code

### LEAN 4 Syntax Requirements
- LEAN 4 syntax is strict; use `#check` and `#eval` to verify expressions
- Always check for implicit arguments when applying theorems
- Use `sorry` temporarily, but never commit unproven theorems

### Common Patterns
- Use `by` blocks for tactic proofs
- Use `where` for local definitions
- Use `have` for intermediate steps with named hypotheses
- Use `calc` for equational reasoning

### Refer to Style Guide
- Follow `docs/development/LEAN_STYLE_GUIDE.md` for all code
- 100-character line limit, 2-space indentation
- Flush-left declarations (no indentation after `def`/`theorem`)

### TDD Enforcement
- Every new feature requires tests first
- Run `lake test` before committing
- CI will reject PRs with failing tests or missing coverage

### Common Errors
- Missing implicit arguments: Use `@function` for explicit application
- Universe issues: Check `Type u` annotations
- Dependent type errors: Ensure propositions are `Prop`, not `Bool`
- Tactic failures: Use `trace` or `sorry` to debug incrementally

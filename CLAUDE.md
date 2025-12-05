# CLAUDE.md - Logos Project Configuration

## 1. Project Overview

Logos is a LEAN 4 implementation of an axiomatic proof system for the bimodal
logic TM (Tense and Modality) with task semantics. It provides:

- **Bimodal Logic TM**: Combining S5 modal logic (metaphysical necessity/possibility) with linear temporal logic (past/future operators)
- **Task Semantics**: Possible worlds as functions from times to world states constrained by task relations
- **Layered Architecture**: Layer 0 (Core TM) MVP complete with planned extensions for counterfactual, epistemic, and normative operators
- **Complete Soundness**: All 8 axioms and 7 inference rules proven sound
- **Perpetuity Principles**: All 6 principles (P1-P6) available

## Implementation Status

**MVP Completion**: Layer 0 (Core TM) MVP complete with full soundness

**For detailed status**: See [Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
**For limitations**: See [Implementation Status - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations)
**For task tracking**: See [TODO.md](TODO.md) (active work only - git history for completed tasks)
**For technical debt**: See [Documentation/ProjectInfo/SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md)
**For maintenance workflow**: See [Documentation/ProjectInfo/MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md)

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
Logos/Core/
├── Logos.lean           # Library root (re-exports all public modules)
├── Logos/Core/               # Main source directory (see Logos/Core/README.md)
│   ├── Syntax/                 # Formula types, parsing, DSL
│   │   ├── Formula.lean        # Core formula inductive type
│   │   └── Context.lean        # Proof context (premise lists)
│   ├── ProofSystem/            # Axioms and inference rules
│   │   ├── Axioms.lean         # TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
│   │   └── Derivation.lean     # Derivability relation and inference rules (MP, MK, TK, TD)
│   ├── Semantics/              # Task frame semantics
│   │   ├── TaskFrame.lean      # Task frame structure
│   │   ├── WorldHistory.lean   # World history definition
│   │   ├── TaskModel.lean      # Model with valuation
│   │   ├── Truth.lean          # Truth evaluation
│   │   └── Validity.lean       # Validity and consequence
│   ├── Metalogic/              # Soundness and completeness
│   │   ├── Soundness.lean      # Soundness theorem
│   │   └── Completeness.lean   # Completeness theorem (canonical model)
│   ├── Theorems/               # Key theorems
│   │   └── Perpetuity.lean     # P1-P6 perpetuity principles
│   └── Automation/             # Proof automation
│       ├── Tactics.lean        # Custom tactics (modal_k, temporal_k, etc.)
│       └── ProofSearch.lean    # Automated proof search
├── LogosTest/           # Test suite (see LogosTest/README.md)
│   ├── LogosTest.lean   # Test library root
│   ├── Syntax/                 # Tests for formula construction and parsing
│   ├── ProofSystem/            # Tests for axioms and inference rules
│   ├── Semantics/              # Tests for task semantics and validity
│   ├── Integration/            # Cross-module integration tests
│   └── Metalogic/              # Soundness/completeness tests
├── Archive/                    # Pedagogical examples (see Archive/README.md)
│   ├── Archive.lean            # Archive library root
│   └── BimodalProofs.lean      # Combined modal-temporal examples
├── Documentation/              # User documentation (see Documentation/README.md)
│   ├── UserGuide/              # User-facing documentation
│   │   ├── ARCHITECTURE.md         # System design and TM logic specification
│   │   ├── TUTORIAL.md             # Getting started guide
│   │   ├── EXAMPLES.md             # Usage examples
│   │   └── INTEGRATION.md          # Model-Checker integration
│   ├── ProjectInfo/            # Project status and contribution info
│   │   ├── IMPLEMENTATION_STATUS.md  # Module-by-module status tracking (includes Known Limitations)
│   │   ├── SORRY_REGISTRY.md         # Technical debt (sorry placeholders)
│   │   ├── MAINTENANCE.md            # TODO management workflow
│   │   ├── CONTRIBUTING.md           # Contribution guidelines
│   │   └── VERSIONING.md             # Semantic versioning policy
│   ├── Development/            # Developer standards
│   │   ├── LEAN_STYLE_GUIDE.md     # Coding conventions
│   │   ├── MODULE_ORGANIZATION.md  # Directory structure
│   │   ├── TESTING_STANDARDS.md    # Test requirements
│   │   ├── TACTIC_DEVELOPMENT.md   # Custom tactic patterns
│   │   └── QUALITY_METRICS.md      # Quality targets
│   └── Reference/              # Reference materials
│       └── OPERATORS.md              # Formal symbols reference
├── lakefile.toml               # LEAN 4 build configuration
├── lean-toolchain              # LEAN version pinning
├── .gitignore                  # Git exclusions
└── .github/workflows/ci.yml    # CI/CD pipeline
```

## 4. Documentation Index

### Developer Standards (Documentation/Development/)
- [LEAN Style Guide](Documentation/Development/LEAN_STYLE_GUIDE.md) - Naming, formatting, documentation
- [Module Organization](Documentation/Development/MODULE_ORGANIZATION.md) - Directory structure, namespaces
- [Testing Standards](Documentation/Development/TESTING_STANDARDS.md) - Test types, coverage requirements
- [Tactic Development](Documentation/Development/TACTIC_DEVELOPMENT.md) - Custom tactic patterns
- [Quality Metrics](Documentation/Development/QUALITY_METRICS.md) - Coverage, lint, performance targets
- [Directory README Standard](Documentation/Development/DIRECTORY_README_STANDARD.md) - Directory-level documentation standard

### Project Status (Keep Updated)
- [TODO.md](TODO.md) - **Active task tracking** (uses git-based history model)
- [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status tracking
- [Implementation Status - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) - Gaps and workarounds
- [Sorry Registry](Documentation/ProjectInfo/SORRY_REGISTRY.md) - Technical debt (sorry placeholders)
- [Maintenance Workflow](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management procedures

### User Documentation (Documentation/UserGuide/ and Documentation/ProjectInfo/)
- [Logos Methodology](Documentation/UserGuide/METHODOLOGY.md) - Philosophical foundations and layer architecture
- [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md) - System design and TM logic specification
- [Logical Operators Glossary](Documentation/Reference/OPERATORS.md) - Formal symbols reference
- [Terminology Glossary](Documentation/Reference/GLOSSARY.md) - Key concepts and definitions
- [Tutorial](Documentation/UserGuide/TUTORIAL.md) - Getting started with Logos
- [Examples](Documentation/UserGuide/EXAMPLES.md) - Modal, temporal, bimodal examples
- [Contributing](Documentation/ProjectInfo/CONTRIBUTING.md) - How to contribute
- [Integration](Documentation/UserGuide/INTEGRATION.md) - Model-Checker integration
- [Versioning](Documentation/ProjectInfo/VERSIONING.md) - Semantic versioning policy

### Research Documentation (Documentation/Research/)
- [Research Overview](Documentation/Research/README.md) - Research documentation index
- [Dual Verification](Documentation/Research/DUAL_VERIFICATION.md) - RL training architecture
- [Proof Library Design](Documentation/Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching architecture
- [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md) - Layers 1-3 specifications

### Symbol Formatting Standards
- [Documentation Standards - Formal Symbol Backtick Standard](.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard) - Backtick requirements for Unicode symbols in Markdown
- [LEAN Style Guide - Code Comments with Formal Symbols](Documentation/Development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols) - Backtick usage in LEAN code comments

### Claude Code Framework Documentation

For comprehensive Claude Code development standards and patterns, see:
- [Code Standards](.claude/docs/reference/standards/code-standards.md) - Coding conventions, error handling, bash patterns, LEAN 4 standards
- [Testing Protocols](.claude/docs/reference/standards/testing-protocols.md) - Test organization, coverage requirements, performance benchmarks
- [Documentation Standards](.claude/docs/reference/standards/documentation-standards.md) - README requirements, format standards, LEAN 4 docstrings
- [Command Development](.claude/docs/guides/development/command-development/command-development-fundamentals.md) - Creating slash commands
- [Agent Development](.claude/docs/guides/development/agent-development/agent-development-fundamentals.md) - Creating specialized agents

## 5. Development Principles

Logos follows rigorous development standards including Test-Driven Development (TDD), fail-fast error handling, comprehensive documentation requirements, and lint compliance.

**For complete guidelines**, see:
- [Code Standards](.claude/docs/reference/standards/code-standards.md) - TDD principles, fail-fast philosophy, LEAN 4 syntax patterns, common errors
- [Testing Protocols](.claude/docs/reference/standards/testing-protocols.md) - Test organization, coverage requirements, performance benchmarks
- [Documentation Standards](.claude/docs/reference/standards/documentation-standards.md) - Docstring requirements, module documentation format

**Quick Reference**:
- **TDD**: Write failing test → minimal implementation → refactor
- **Fail-Fast**: Functions fail immediately on invalid input
- **Documentation**: Every public definition requires docstring
- **Lint**: Zero #lint warnings required

## 6. Key Packages

### Syntax Package
- `Formula`: Inductive type for TM formulas (atom, bot, imp, box, all_past, all_future)
- `Context`: Proof contexts (premise lists)
- DSL macros for readable formula construction **(planned)**
- Derived operators: `some_past`, `some_future`, `always`, `sometimes`
- Temporal duality: `swap_temporal` swaps all_past and all_future

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
- `soundness`: `Γ ⊢ φ → Γ ⊨ φ` **(partial: 5/8 axioms, 4/7 rules proven)**
  - Proven axioms: MT, M4, MB, T4, TA
  - Incomplete axioms: TL, MF, TF (require frame constraints)
  - Proven rules: axiom, assumption, modus_ponens, weakening
  - Incomplete rules: modal_k, temporal_k, temporal_duality
- `weak_completeness`: `⊨ φ → ⊢ φ` **(infrastructure only, no proofs)**
- `strong_completeness`: `Γ ⊨ φ → Γ ⊢ φ` **(infrastructure only, no proofs)**
- Canonical model construction defined (types, no proofs)

### Theorems Package
- Perpetuity principles P1-P6 connecting modal and temporal operators:
  - P1: `□φ → △φ` (necessary implies always) - **Proven (uses imp_trans helper with sorry)**
  - P2: `▽φ → ◇φ` (sometimes implies possible) - **Proven (uses contraposition helper with sorry)**
  - P3: `□φ → □△φ` (necessity of perpetuity) - **Fully proven (zero sorry)**
  - P4: `◇▽φ → ◇φ` (possibility of occurrence) - **Partial (complex nested formulas)**
  - P5: `◇▽φ → △◇φ` (persistent possibility) - **Partial (modal-temporal interaction)**
  - P6: `▽□φ → □△φ` (occurrent necessity is perpetual) - **Partial (modal-temporal interaction)**
- Note: `△` (always/at all times) and `▽` (sometimes/at some time) are Unicode triangle notation alternatives

### Automation Package
- `Tactics`: Custom tactic declarations **(stubs only, no implementations)**
  - All 12 tactics are function signatures with `sorry` bodies
  - Includes: modal_k, temporal_k, modal_t, modal_search, tm_auto, etc.
- `ProofSearch`: Automated proof search **(planned, not started)**

## 7. Testing Architecture

Logos test suite is organized in LogosTest/ directory with unit tests (Syntax/, ProofSystem/, Semantics/), integration tests (Integration/), and metalogic property tests (Metalogic/).

**Test Naming Convention**:
- Files: `<Module>Test.lean` (e.g., `FormulaTest.lean`)
- Tests: `test_<feature>_<expected_behavior>` (e.g., `test_modal_t_valid`)

**For complete testing standards and quality metrics**, see [Testing Protocols](.claude/docs/reference/standards/testing-protocols.md).

## 8. Quality Standards

**Coverage Targets**: Overall ≥85%, Metalogic ≥90%, Automation ≥80%, Error handling ≥75%

**Lint Requirements**: Zero #lint warnings, 100% docBlame/docBlameThm coverage

**Performance Benchmarks**: Build <2min, Test <30sec, Proof search <1sec, Docs <1min

**For complete quality metrics and complexity limits**, see [Testing Protocols](.claude/docs/reference/standards/testing-protocols.md).

## 9. Common Tasks

### Add a New Axiom
1. Define axiom schema in `ProofSystem/Axioms.lean`
2. Add case to `Derivable` in `ProofSystem/Derivation.lean`
3. Prove validity lemma in `Metalogic/Soundness.lean`
4. Write tests in `LogosTest/ProofSystem/`
5. Document with examples

### Create a Custom Tactic
1. Define tactic in `Automation/Tactics.lean`
2. Write unit tests in `LogosTest/Automation/`
3. Add example usage to `Archive/`
4. Document in `Documentation/Development/TACTIC_DEVELOPMENT.md`

### Add a New Theorem
1. Write failing test in appropriate `LogosTest/` directory
2. Prove theorem in `Theorems/` or relevant module
3. Add docstring with mathematical statement and proof sketch
4. Update documentation if theorem is significant

### Prove Soundness for New Axiom
1. Add validity lemma to `Metalogic/Soundness.lean`
2. Prove axiom valid in all task semantic models
3. Add case to main `soundness` theorem
4. Test with example formulas

## 10. Notes for Claude Code

**LEAN 4 Syntax**: LEAN 4 syntax is strict. Use `#check`, `#eval` to verify expressions. Never commit unproven theorems (`sorry`).

**Common Patterns**: Use `by` for tactic proofs, `where` for local definitions, `have` for intermediate steps, `calc` for equational reasoning.

**For complete LEAN 4 patterns, error handling, and TDD guidance**, see:
- [Code Standards](.claude/docs/reference/standards/code-standards.md) - LEAN 4 syntax requirements, common patterns, TDD enforcement, common errors
- [LEAN Style Guide](Documentation/Development/LEAN_STYLE_GUIDE.md) - 100-char line limit, 2-space indentation, flush-left declarations

**TDD Enforcement**: Every new feature requires tests first. Run `lake test` before committing. CI rejects PRs with failing tests.

**Working with Partial Implementation**:
- **Use proven components only**: MT, M4, MB, T4, TA axioms are sound
- **Avoid incomplete axioms**: TL, MF, TF have incomplete soundness proofs
- **Perpetuity P3 is safe**: Only P3 is fully proven (zero sorry)
- **No automation available**: All tactics are stubs, use manual proof construction
- See [Implementation Status - Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations) for workarounds and alternatives
- See [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
  for verification commands

### LEAN 4 Metaprogramming and Automation Quick Reference

This section provides quick reference for implementing custom tactics and automation
for Logos's TM logic.

**Tactic Development Approach**:
- Use `elab_rules` for pattern-matched tactics (recommended for most tactics)
- Use macro-based approach for simple tactic sequences
- Use direct TacticM for complex iteration/search (e.g., `assumption_search`)
- See [METAPROGRAMMING_GUIDE.md](Documentation/Development/METAPROGRAMMING_GUIDE.md)
  for complete API reference

**Automation Strategy**:
- Integrate with Aesop for proof search automation
- Create TMLogic rule set: `declare_aesop_rule_sets [TMLogic]`
- Mark axioms as safe rules: `@[aesop safe [TMLogic]]`
- Implement `tm_auto` tactic: `macro "tm_auto" : tactic => `(tactic| aesop
  (rule_sets [TMLogic]))`
- See [TACTIC_DEVELOPMENT.md](Documentation/Development/TACTIC_DEVELOPMENT.md)
  Section 4 for Aesop integration

**Priority Tactics** (from TODO.md Task 7, 40-60 hours):
1. `apply_axiom` - Apply specific TM axiom (8-10 hours, macro-based)
2. `modal_t` - Apply modal axiom MT (`□φ → φ`) (4-6 hours, elab_rules)
3. `tm_auto` - Comprehensive TM automation with Aesop (15-20 hours, macro + Aesop)
4. `assumption_search` - Search context for matching assumptions (8-12 hours,
   TacticM)

**Key Metaprogramming Modules**:
- `Lean.Elab.Tactic` - High-level tactic monad (TacticM)
- `Lean.Meta.Basic` - Meta-level operations (mkAppM, mkConst)
- `Lean.Expr` - Expression representation and pattern matching
- `Lean.MVarId` - Goal identifier and operations (getMainGoal, assign)

**Aesop Integration Pattern**:

```lean
-- Declare custom rule set
declare_aesop_rule_sets [TMLogic]

-- Mark axiom as safe rule
@[aesop safe [TMLogic]]
theorem modal_t_derivable (φ : Formula) :
  Derivable [] (Formula.box φ).imp φ := by
  apply Derivable.axiom
  exact Axiom.modal_t φ

-- Implement tm_auto tactic
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))
```

**Simp Lemma Design** (for modal/temporal simplifications):
- Modal simplifications: `box_box_eq_box` (`□□φ = □φ`), `diamond_diamond_eq_diamond`
  (`◇◇φ = ◇φ`)
- Temporal simplifications: `future_future_eq_future` (FFφ = Fφ),
  `past_past_eq_past` (PPφ = Pφ)
- Bimodal interactions: `box_future_eq_future_box` (`□Fφ = F□φ`),
  `box_past_eq_past_box` (`□Pφ = P□φ`)
- **Important**: Must be proven as theorems in TM, not asserted as axioms
- See [TACTIC_DEVELOPMENT.md](Documentation/Development/TACTIC_DEVELOPMENT.md)
  Section 5 for simp lemma design

**Implementation Roadmap**:
- See [PHASED_IMPLEMENTATION.md](Documentation/Development/PHASED_IMPLEMENTATION.md)
  for Wave 1-4 execution strategy
- Task 7 (Implement Core Automation): 40-60 hours, phased approach
- Wave 2 execution: Task 7 can run in parallel with Tasks 5, 6, 8
- Time savings: 25-32% with proper parallelization

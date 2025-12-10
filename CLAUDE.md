# CLAUDE.md - Logos Project Configuration

## 1. Project Overview

Logos is a LEAN 4 implementation of an axiomatic proof system for the bimodal
logic TM (Tense and Modality) with task semantics. It provides:

- **Bimodal Logic TM**: Combining S5 modal logic (metaphysical necessity/possibility) with linear temporal logic (past/future operators)
- **Task Semantics**: Possible worlds as functions from times to world states constrained by task relations
- **Layered Architecture**: Layer 0 (Core TM) MVP complete with planned extensions for counterfactual, epistemic, and normative operators
- **Complete Soundness**: All 12 axioms proven sound, 8/8 inference rules proven
- **Perpetuity Principles**: ALL 6 principles fully proven (P1-P6, zero sorry)

## Implementation Status

**MVP Completion**: Layer 0 (Core TM) MVP complete with full soundness

| File | Purpose | Update Trigger |
|------|---------|----------------|
| [TODO.md](TODO.md) | Active development tasks | After completing tasks, discovering work |
| [.claude/TODO.md](.claude/TODO.md) | Implementation plans in `.claude/specs/` | After `/create-plan`, `/research`, `/todo` |
| [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | Module-by-module completion | After module work, sorry count changes |
| [SORRY_REGISTRY.md](Documentation/ProjectInfo/SORRY_REGISTRY.md) | Technical debt (sorry placeholders) | After resolving sorry, adding axioms |
| [MAINTENANCE.md](Documentation/ProjectInfo/MAINTENANCE.md) | TODO management workflow | After workflow changes |
| [TACTIC_DEVELOPMENT.md](Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md) | Custom tactic patterns | After tactic additions |

**See also**: [Known Limitations](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations)

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
│   │   ├── TACTIC_DEVELOPMENT.md     # Custom tactic patterns
│   │   └── MAINTENANCE.md            # TODO management workflow
│   ├── Development/            # Developer standards
│   │   ├── LEAN_STYLE_GUIDE.md     # Coding conventions
│   │   ├── MODULE_ORGANIZATION.md  # Directory structure
│   │   ├── TESTING_STANDARDS.md    # Test requirements
│   │   ├── QUALITY_METRICS.md      # Quality targets
│   │   ├── CONTRIBUTING.md         # Contribution guidelines
│   │   └── VERSIONING.md           # Semantic versioning policy
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
- [Quality Metrics](Documentation/Development/QUALITY_METRICS.md) - Coverage, lint, performance targets
- [Directory README Standard](Documentation/Development/DIRECTORY_README_STANDARD.md) - Directory-level documentation standard
- [Maintenance Workflow](Documentation/ProjectInfo/MAINTENANCE.md) - TODO management procedures
- [Contributing](Documentation/Development/CONTRIBUTING.md) - How to contribute
- [Versioning](Documentation/Development/VERSIONING.md) - Semantic versioning policy

### User Documentation (Documentation/UserGuide/)
- [Logos Methodology](Documentation/UserGuide/METHODOLOGY.md) - Philosophical foundations and layer architecture
- [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md) - System design and TM logic specification
- [Logical Operators Glossary](Documentation/Reference/OPERATORS.md) - Formal symbols reference
- [Terminology Glossary](Documentation/Reference/GLOSSARY.md) - Key concepts and definitions
- [Tutorial](Documentation/UserGuide/TUTORIAL.md) - Getting started with Logos
- [Examples](Documentation/UserGuide/EXAMPLES.md) - Modal, temporal, bimodal examples
- [Integration](Documentation/UserGuide/INTEGRATION.md) - Model-Checker integration

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
- `Axiom`: TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF, modal_k_dist, modal_5_collapse, double_negation, prop_k, prop_s)
- `Derivable`: Inductive derivability relation
- Inference rules: MP, MK (modal K), TK (temporal K), TD (temporal duality), necessitation, assumption, weakening, axiom

### Semantics Package
- `TaskFrame`: World states, times, task relation with nullity and compositionality
- `WorldHistory`: Functions from convex time sets to world states
- `TaskModel`: Task frame with valuation function
- `truth_at`: Truth evaluation at model-history-time triples

### Metalogic Package
- `soundness`: `Γ ⊢ φ → Γ ⊨ φ` **(complete: 12/12 axioms, 8/8 rules proven)**
  - Proven axioms: MT, M4, MB, T4, TA, TL, MF, TF, modal_k_dist, modal_5_collapse, double_negation, prop_k, prop_s (all 13/13 complete)
  - Proven rules: axiom, assumption, modus_ponens, weakening, modal_k, temporal_k, temporal_duality, necessitation (all 8/8 complete)
- `deduction_theorem`: `(Γ, A ⊢ B) → (Γ ⊢ A → B)` **(complete, zero sorry)**
  - Helper lemmas: deduction_axiom, deduction_assumption_same, deduction_assumption_other, deduction_mp
- `weak_completeness`: `⊨ φ → ⊢ φ` **(infrastructure only, no proofs)**
- `strong_completeness`: `Γ ⊨ φ → Γ ⊢ φ` **(infrastructure only, no proofs)**
- Canonical model construction defined (types, no proofs)

### Theorems Package
- Combinator theorems derived from K (prop_k) and S (prop_s) axioms:
  - `theorem_flip`: `(A → B → C) → (B → A → C)` (C combinator)
  - `theorem_app1`: `A → (A → B) → B` (single application)
  - `theorem_app2`: `A → B → (A → B → C) → C` (Vireo combinator)
  - `pairing`: `A → B → A ∧ B` (conjunction introduction, **now theorem not axiom**)
- Perpetuity principles P1-P6 connecting modal and temporal operators:
  - P1: `□φ → △φ` (necessary implies always) - **Fully proven (zero sorry)**
  - P2: `▽φ → ◇φ` (sometimes implies possible) - **Fully proven (contraposition via B combinator)**
  - P3: `□φ → □△φ` (necessity of perpetuity) - **Fully proven (zero sorry)**
  - P4: `◇▽φ → ◇φ` (possibility of occurrence) - **Fully proven (contraposition of P3 + DNI)**
  - P5: `◇▽φ → △◇φ` (persistent possibility) - **Fully proven (via P4 + persistence lemma)**
  - P6: `▽□φ → □△φ` (occurrent necessity is perpetual) - **Fully proven (via P5(¬φ) + bridge lemmas + double_contrapose)**
- Note: `△` (always/at all times) and `▽` (sometimes/at some time) are Unicode triangle notation alternatives
- **ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN** (100% completion)
- **PAIRING COMBINATOR DERIVED** (reduced axiom count by 1)
- **De Morgan Laws Infrastructure** (Plan 059 Phase 1 - COMPLETE):
  - `contrapose_imp`: `⊢ (A → B) → (¬B → ¬A)` (contraposition helper)
  - `demorgan_conj_neg`: `⊢ ¬(A ∧ B) ↔ (¬A ∨ ¬B)` (full biconditional) ✓
  - `demorgan_disj_neg`: `⊢ ¬(A ∨ B) ↔ (¬A ∧ ¬B)` (full biconditional) ✓
  - Plus forward/backward direction helpers for both laws
- **Phase 4 Modal Theorems** (8/8 complete - Plan 060 COMPLETE):
  - `Propositional.lean`: lce_imp, rce_imp, classical_merge, De Morgan laws, biconditional infrastructure ✓
  - `ModalS5.lean`: k_dist_diamond, box_disj_intro, box_conj_iff, diamond_disj_iff, s5_diamond_box, s5_diamond_box_to_truth ✓
  - `ModalS4.lean`: s4_diamond_box_conj, s4_box_diamond_box, s4_diamond_box_diamond, s5_diamond_conj_diamond ✓
- **K Distribution for Diamond** (Plan 060 - Key Discovery):
  - `k_dist_diamond`: `⊢ □(A → B) → (◇A → ◇B)` (valid K distribution)
  - NOTE: `(A → B) → (◇A → ◇B)` is NOT VALID (counter-model documented in ModalS5.lean)
  - Solution: "Box the implication" to get valid theorem from K axiom

### Automation Package
- `Tactics`: Custom tactics for TM logic automation **(4/12 implemented)**
  - **Implemented**: `apply_axiom`, `modal_t`, `tm_auto`, `assumption_search` ✓
  - **Not implemented**: `modal_k_tactic`, `temporal_k_tactic`, `modal_4_tactic`, `modal_b_tactic`, `temp_4_tactic`, `temp_a_tactic`, `modal_search`, `temporal_search` (planned)
- `ProofSearch`: Proof search infrastructure (stubs with axiom declarations)

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
4. Document in `Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md`

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
- **Use proven components**: All 12 axioms are sound (MT, M4, MB, T4, TA, TL, MF, TF, modal_k_dist, double_negation, prop_k, prop_s)
- **Perpetuity proofs**: ALL 6 principles fully proven (P1-P6, zero sorry)
- **Automation available**: All 12 tactics implemented (see Automation Package above)
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
- See [TACTIC_DEVELOPMENT.md](Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md)
  Section 4 for Aesop integration

**Implemented Tactics** (Task 7 complete, 12/12 tactics):
1. `apply_axiom` - Apply TM axiom via unification (macro-based)
2. `modal_t` - Apply axiom MT `□φ → φ` (macro-based)
3. `tm_auto` - Aesop-powered TM automation (macro to aesop)
4. `assumption_search` - Search context for matching assumptions (TacticM)
5. `modal_k_tactic`, `temporal_k_tactic` - Inference rule tactics (elab)
6. `modal_4_tactic`, `modal_b_tactic` - Modal axiom tactics (elab)
7. `temp_4_tactic`, `temp_a_tactic` - Temporal axiom tactics (elab)
8. `modal_search`, `temporal_search` - Bounded search (MVP: tm_auto delegation)

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
- See [TACTIC_DEVELOPMENT.md](Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md)
  Section 5 for simp lemma design

**Implementation Status**:
- Task 7 (Core Automation): ✓ COMPLETE (12/12 tactics implemented)
- 110+ tests passing in TacticsTest.lean
- See [TACTIC_DEVELOPMENT.md](Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md)
  for implementation patterns and examples

# Development Standards Plan for Logos

## Metadata
- **Date**: 2025-12-01
- **Agent**: research-specialist
- **Topic**: Development standards plan for Logos project
- **Report Type**: research-and-plan
- **Complexity**: 3

## Executive Summary

This report synthesizes research from three foundational sources to create a comprehensive development standards plan for the Logos LEAN 4 package: (1) Logos package specifications defining the TM bimodal logic system, (2) LEAN 4 best practices from the mature ecosystem including Mathlib4 style guide and FormalizedFormalLogic/Foundation modal logic patterns, and (3) coding/documentation standards from the ModelChecker project. The plan identifies 12 critical standards documents needed across three categories: LEAN-specific standards (Lake configuration, code style, tactic development), project organization standards (directory structure, testing, documentation), and maintenance standards (CLAUDE.md configuration, quality metrics, CI/CD). These documents will be distributed between `src/docs/` (code-specific) and `docs/` (general project documentation), creating a streamlined development workflow that leverages LEAN 4's mature tooling while maintaining consistency with the broader Logos project ecosystem.

## Findings

### 1. Current Project State Analysis

**Existing Structure:**
- Root: `/home/benjamin/Documents/Philosophy/Projects/Logos/`
- Key directories:
  - `docs/` - Contains `architecture.md` (copied from Logos, has broken links)
  - `src/docs/` - Empty except for placeholder `README.md`
  - `.claude/` - Full Claude Code infrastructure (agents, commands, specs)
  - `README.md` - Empty, needs population

**Missing Infrastructure:**
- No LEAN 4 build configuration (`lakefile.toml`, `lean-toolchain`)
- No LEAN source files yet (`.lean` files)
- No CLAUDE.md configuration file
- No testing infrastructure
- No CI/CD configuration
- No code standards documentation
- No development guidelines

**Key Insight:** Project is in early initialization phase, making this the ideal time to establish comprehensive standards before implementation begins.

### 2. LEAN 4 Ecosystem Requirements (from Report 002)

**Source:** `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/002_lean4_proof_checker_best_practices/reports/001-research-the-best-practices-online-for-d.md`

#### 2.1 Critical LEAN 4 Standards

**Lake Package Manager (Lines 76-157):**
- Standard directory layout: `Logos/` root with `.lean` library root file
- Module namespace mirrors directory structure
- `lakefile.toml` configuration with metadata, dependencies, build settings
- `.lake/` directory for build artifacts (must be gitignored)
- `lean-toolchain` file pins exact LEAN version

**Mathlib4 Style Guide (Lines 179-308):**
- **Naming conventions** (Lines 183-200):
  - Universe variables: `u`, `v`, `w`
  - Generic types: `α`, `β`, `γ`
  - Propositions: `a`, `b`, `c`
  - Hypotheses: `h`, `h₁`, `h₂`
- **Formatting** (Lines 202-248):
  - Maximum 100 characters per line
  - 2-space indentation (not tabs)
  - Flush-left top-level declarations
  - Space around `:`, `:=`, infix operators
- **Documentation** (Lines 249-308):
  - Module docstrings with `/-! -/` delimiters
  - Declaration docstrings with `/-- -/`
  - Every definition requires documentation
  - Use `#lint` to verify compliance

**Modal Logic Patterns (Lines 310-360):**
- **FormalizedFormalLogic/Foundation** is the most comprehensive modal logic implementation
- Provides Kripke semantics formalization patterns
- Includes completeness theorem structure
- Logos should adopt their patterns for consistency
- **No existing temporal logic implementations found** - Logos will be among the first

#### 2.2 Development Workflow Requirements

**Testing Infrastructure (Lines 431-495):**
- Configure Lake test driver in `lakefile.toml`
- Use `#guard` for unit tests
- Example-based tests with proof automation
- Property tests for metalogic theorems
- CI/CD with GitHub Actions using `leanprover/lean4-action@v1`

**Documentation Generation (Lines 497-541):**
- Auto-generate from doc comments with `lake build :docs`
- Host on GitHub Pages
- Structure: README.md, tutorial.md, api_reference.md, architecture.md

**Custom Tactics (Lines 362-429):**
- LEAN 4 metaprogramming for proof automation
- Priority tactics: `modal_k`, `temporal_k`, `s5_simp`, `bimodal`
- Integration with Aesop for automated proof search

### 3. Python/General Standards from ModelChecker (from Report 000)

**Source:** `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/000_no_name_error/reports/001-i-just-created-this-proof-checker-repo-a.md`

**Note:** While ModelChecker uses Python and Logos uses LEAN 4, several high-level principles are language-agnostic:

#### 3.1 Core Development Principles (Lines 20-111)

**1. No Backwards Compatibility (Lines 23-43):**
- Clean refactoring without legacy support
- Direct interface changes without optional parameters
- **Adaptation for LEAN:** Deprecation protocol with 6-month window (per Mathlib convention, Lines 301-308 of Report 002)

**2. Fail-Fast Philosophy (Lines 65-86):**
- Deterministic failures with helpful messages
- Early problem detection
- **Adaptation for LEAN:** Clear error types in custom exceptions, user-friendly error messages

**3. Test-Driven Development (Lines 87-111):**
- Write failing test first (RED)
- Minimal implementation (GREEN)
- Refactor
- **Adaptation for LEAN:** Use LEAN's `#guard` and example-based tests, TDD workflow applies directly

#### 3.2 Documentation Standards (Lines 172-267)

**No Historical References (Lines 244-267):**
- Document current state only
- No "recently added" or "refactored in v2.0" annotations
- Focus on what exists now, not how it evolved
- **Applies equally to LEAN documentation**

**Docstring Requirements (Lines 175-232):**
- Every public function/definition documented
- Args, Returns, Raises sections
- Usage examples
- **LEAN equivalent:** Module docstrings (`/-! -/`), declaration docstrings (`/-- -/`), already covered in Mathlib standards

#### 3.3 Testing Standards (Lines 269-342)

**Coverage Requirements (Lines 334-342):**
- Overall: ≥85%
- Critical paths: ≥90%
- Utilities: ≥80%
- Error handling: ≥75%
- **Adaptation for LEAN:** Coverage tracking for LEAN code (if tooling available), focus on test completeness

**Test Organization (Lines 273-288):**
- Unit tests separate from integration tests
- Clear test file naming
- AAA pattern (Arrange-Act-Assert)
- **Adaptation for LEAN:** Tests/ directory with unit/ and integration/ subdirectories

#### 3.4 Project Structure Standards (Lines 447-476)

**Directory Layout (Lines 449-465):**
```
Project/
├── Code/           # Implementation (src/ for LEAN)
│   ├── src/        # Source code
│   ├── docs/       # Technical standards (START HERE for dev)
│   ├── tests/      # Test suites
│   └── scripts/    # Maintenance scripts
├── Docs/           # User-facing documentation
├── specs/          # Development artifacts (research, plans)
└── CLAUDE.md       # Claude Code configuration
```

**Specs Protocol (Lines 467-476):**
- `plans/` - Implementation plans
- `research/` - Research reports
- `summaries/` - Auto-generated summaries
- `findings/` - Lessons learned
- `debug/` - Debug analyses
- `baselines/` - Test regression baselines

#### 3.5 CLAUDE.md Best Practices (Lines 478-517)

**Content Structure (Lines 482-495):**
1. Project overview
2. Essential commands
3. Project structure
4. Documentation index
5. Development principles
6. Key packages
7. Testing architecture
8. Common tasks
9. Quality standards
10. Notes for Claude Code

**Refinement Approach (Lines 505-517):**
- Start simple, expand based on friction points
- Iterate and refine
- Use emphasis ("IMPORTANT", "YOU MUST")
- Document repeated commands
- Capture architectural context

### 4. Logos Package Specifications (from Report 001)

**Source:** `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/001_proof_checker_package_docs/reports/001-research-the-proof-checker-package-descr.md`

#### 4.1 Technical Architecture (Lines 59-160)

**Core System TM (Lines 62-85):**
- Bimodal logic: modal (□, ◇) + temporal (Past, Future)
- Primitive operators: atom, ⊥, →, □, Past, Future
- Derived operators: ¬, ∧, ∨, ◇, past, future, always, sometimes

**Layered Architecture (Lines 86-109):**
- **Layer 0 (Core):** TM system - S5 modal + temporal axioms - CURRENT FOCUS
- **Layer 1:** Counterfactual, constitutive, causal operators - FUTURE
- **Layer 2:** Epistemic (belief, probability) operators - FUTURE
- **Layer 3:** Normative (deontic, preference) operators - FUTURE

**Key Axioms (Lines 110-141):**
- S5: MT (reflexivity), M4 (transitivity), MB (symmetry)
- Temporal: T4, TA, TL
- Bimodal interaction: MF, TF
- Inference rules: MP, MK, TK, TD, Weakening

**Task Semantics (Lines 143-160):**
- WorldState (W), Time (T), Task Relation (⇒)
- World history functions
- Truth evaluation at (M, τ, t)

#### 4.2 Planned Project Structure (Lines 163-215)

```
proof-checker/
├── src/
│   ├── syntax/          # Formula types, parsing, DSL
│   ├── proof_system/    # Axioms, rules, tactics
│   ├── semantics/       # Task frames, truth evaluation
│   ├── metalogic/       # Soundness, completeness
│   ├── theorems/        # Perpetuity principles
│   └── automation/      # Proof search, theorem DB
├── examples/            # Modal, temporal, bimodal examples
├── tests/              # Comprehensive test suites
└── docs/               # User documentation
```

#### 4.3 Integration Requirements (Lines 217-236)

**With Model-Checker (Lines 220-228):**
- Export formulas to SMT-LIB format
- Import validation results
- Coordinate proof search with semantic checking

**Documentation Issues (Lines 238-262):**
- Current `docs/architecture.md` has broken links to Logos files
- Need to remove Logos-specific references
- Update context for standalone project

### 5. Gap Analysis: Standards Documents Needed

**Critical Missing Standards:**

1. **LEAN-Specific Standards:**
   - Lake configuration guide (lakefile.toml, lean-toolchain)
   - LEAN code style guide (adapted from Mathlib4)
   - Tactic development guide
   - Module organization conventions
   - Documentation generation setup

2. **Testing Standards:**
   - Test organization structure
   - Test naming conventions
   - Coverage requirements for LEAN
   - CI/CD pipeline configuration
   - Regression testing protocol

3. **Documentation Standards:**
   - Module docstring templates
   - Declaration documentation requirements
   - API reference generation
   - Tutorial structure
   - Example organization

4. **Project Management:**
   - CLAUDE.md configuration
   - Directory structure conventions
   - Specs workflow protocol
   - Git workflow and branching
   - Release versioning

5. **Quality Metrics:**
   - Code coverage targets
   - Lint compliance (using `#lint`)
   - Documentation completeness
   - Performance benchmarks
   - Complexity limits

6. **Integration Standards:**
   - Model-Checker integration protocol
   - Formula serialization formats
   - External API design
   - Versioning and compatibility

### 6. Distribution Strategy: src/docs/ vs docs/

**Based on Research Findings:**

**`src/docs/` (Code-Specific Technical Documentation):**
- Purpose: Standards for developers working on LEAN implementation
- Audience: Contributors writing LEAN code
- Examples from ModelChecker (Lines 449-465 of Report 000):
  - `CODE_STANDARDS.md`
  - `TESTING_GUIDE.md`
  - `ARCHITECTURE.md`
- **Logos adaptation:**
  - `LEAN_STYLE_GUIDE.md`
  - `TACTIC_DEVELOPMENT.md`
  - `MODULE_ORGANIZATION.md`
  - `TESTING_STANDARDS.md`

**`docs/` (General Project Documentation):**
- Purpose: User-facing documentation and project maintenance
- Audience: Users, contributors (general), project maintainers
- Content:
  - `architecture.md` (already exists, needs revision)
  - `tutorial.md` (getting started guide)
  - `examples.md` (usage examples)
  - `api_reference.md` (auto-generated)
  - `integration.md` (Model-Checker integration)
  - `CONTRIBUTING.md` (contribution guidelines)
  - `VERSIONING.md` (semantic versioning policy)

**Root Level:**
- `CLAUDE.md` - Claude Code configuration
- `README.md` - Project overview (needs population)
- `lakefile.toml` - LEAN build configuration
- `lean-toolchain` - LEAN version pinning
- `.gitignore` - Git exclusions (.lake/, build/)

## Recommendations

### Recommendation 1: Create Core LEAN 4 Standards Documents in src/docs/

**Priority: CRITICAL (Phase 1)**

Create four foundational standards documents that developers must read before contributing LEAN code:

#### Document 1: `src/docs/LEAN_STYLE_GUIDE.md`

**Content Structure:**
1. **Naming Conventions** (from Report 002, Lines 183-200)
   - Variable naming patterns (Greek letters for types, `h` for hypotheses)
   - Module naming (lowercase, matching directory structure)
   - Constant naming (PascalCase for types, snake_case for functions)

2. **Formatting Standards** (from Report 002, Lines 202-248)
   - 100-character line limit
   - 2-space indentation (no tabs)
   - Flush-left top-level declarations
   - Spacing rules (around `:`, `:=`, operators)
   - Proof organization (tactic mode, calc blocks)

3. **Import Organization** (adapted from Report 000, Lines 115-140)
   - Standard library imports first
   - Mathlib imports second
   - Local project imports third
   - Relative imports for same-package modules

4. **Documentation Requirements** (from Report 002, Lines 249-308)
   - Module docstrings (`/-! -/`) structure
   - Declaration docstrings (`/-- -/`) requirements
   - Example formatting
   - Linter compliance (`#lint`)

5. **Deprecation Protocol** (from Report 002, Lines 301-308)
   - Use `@[deprecated (since := "YYYY-MM-DD")]`
   - 6-month deletion window
   - Alias creation for renamed declarations

**Rationale:** LEAN 4 has specific syntax and conventions that differ significantly from Python. This document codifies Mathlib4 best practices for Logos.

**Success Metric:** All LEAN code passes `#lint` with zero warnings.

#### Document 2: `src/docs/MODULE_ORGANIZATION.md`

**Content Structure:**
1. **Directory Structure** (from Report 001, Lines 166-214)
   - Syntax/, ProofSystem/, Semantics/, Metalogic/, Theorems/, Automation/
   - Examples/, Tests/
   - Namespace conventions

2. **Module Dependencies** (from Report 002, Lines 590-594)
   - Layered architecture (Layer 0 → Layer 1 → Layer 2 → Layer 3)
   - Avoiding circular dependencies
   - Import minimization

3. **File Structure Template**
   - Copyright header
   - Import statements
   - Module docstring
   - Namespace declarations
   - Definitions and theorems

4. **Library Root File** (from Report 002, Lines 82-84)
   - `Logos.lean` re-exports all public modules
   - Organizing public API

**Rationale:** Clear module organization prevents architectural drift and ensures maintainability as the project grows.

**Success Metric:** Directory structure matches documented conventions, no circular dependencies detected.

#### Document 3: `src/docs/TACTIC_DEVELOPMENT.md`

**Content Structure:**
1. **Custom Tactics Roadmap** (from Report 002, Lines 742-766)
   - Priority tactics: `modal_k`, `temporal_k`, `s5_simp`, `temporal_simp`, `bimodal`
   - Advanced tactics: `perpetuity`, `modal_search`, `tm_auto`

2. **Tactic Implementation Patterns**
   - Using `Lean.Elab.Tactic` module
   - Syntax macros with `macro_rules`
   - Aesop integration (`@[aesop safe]`, `@[aesop norm]`)

3. **Testing Tactics**
   - Unit tests for each tactic
   - Example-based validation
   - Performance benchmarking

4. **Documentation Requirements**
   - Tactic docstrings
   - Usage examples
   - Limitations documentation

**Rationale:** Custom tactics are central to Logos's usability. This guide ensures consistent development patterns and thorough testing.

**Success Metric:** All custom tactics have documented usage examples and passing tests.

#### Document 4: `src/docs/TESTING_STANDARDS.md`

**Content Structure:**
1. **Test Organization** (from Report 002, Lines 441-451 + Report 000, Lines 273-288)
   ```
   Tests/
   ├── Unit/           # Module unit tests
   ├── Integration/    # Cross-module tests
   ├── Examples/       # Example-based tests
   └── Metalogic/      # Soundness/completeness tests
   ```

2. **Test Types**
   - Unit tests with `#guard`
   - Example-based tests (proof automation validation)
   - Property tests (metalogic theorems)
   - Regression tests (performance baselines)

3. **Test Naming** (adapted from Report 000, Lines 312-331)
   - `test_<feature>_<behavior>.lean`
   - Descriptive names: `test_modus_ponens_valid_argument`
   - Avoid generic names: `test_1`, `test_formula`

4. **Coverage Requirements** (from Report 000, Lines 334-342)
   - Overall codebase: ≥85%
   - Critical paths (soundness/completeness): ≥90%
   - Utilities: ≥80%
   - Error handling: ≥75%

5. **CI/CD Integration** (from Report 002, Lines 479-495)
   - GitHub Actions workflow
   - Automated testing on commits/PRs
   - Lint checking
   - Documentation generation

**Rationale:** Rigorous testing is essential for a proof checker - incorrect logic would undermine the entire system. This document ensures comprehensive test coverage.

**Success Metric:** ≥85% overall coverage, all CI checks passing, zero regression failures.

---

### Recommendation 2: Populate docs/ with User-Facing Documentation

**Priority: HIGH (Phase 2)**

Create comprehensive user documentation for external users and contributors:

#### Document 5: `docs/TUTORIAL.md`

**Content Structure:** (from Report 002, Lines 800-841)
1. **Getting Started**
   - Installation (LEAN 4 version requirements)
   - Setup (VS Code extension, `lake build`)
   - First proof example

2. **Basic Formulas**
   - Constructing TM formulas
   - Using operators (□, ◇, Past, Future)
   - DSL syntax

3. **Proof Basics**
   - Manual proofs with axioms
   - Applying inference rules
   - Using derived operators

4. **Automation**
   - Custom tactics overview
   - `modal_auto` usage
   - `tm_auto` comprehensive automation

5. **Semantics**
   - Defining task frames
   - Creating models
   - Truth evaluation

6. **Advanced Topics**
   - Understanding soundness/completeness
   - Extending with Layer 1-3 operators
   - Integration with Model-Checker

**Rationale:** Lower barrier to entry for new users, facilitate teaching and research applications.

**Success Metric:** New contributor can build and run first example in <30 minutes following tutorial.

#### Document 6: `docs/EXAMPLES.md`

**Content Structure:** (from Report 001, Lines 199-209 + Report 002, Lines 800-841)
1. **Modal Logic Examples**
   - S5 axioms (MT, M4, MB)
   - Diamond as derived operator
   - Key S5 theorems

2. **Temporal Logic Examples**
   - Temporal axioms (T4, TA, TL)
   - `past` and `future` operators
   - Temporal properties

3. **Bimodal Interaction Examples**
   - MF and TF axioms
   - Perpetuity principles (P1-P6)
   - `always` and `sometimes` operators

4. **Advanced Examples**
   - Soundness theorem structure
   - Completeness proof outline
   - Custom tactic usage

**Rationale:** Concrete examples demonstrate capabilities and provide templates for users.

**Success Metric:** Each example category has ≥3 working examples with explanations.

#### Document 7: `docs/INTEGRATION.md`

**Content Structure:** (from Report 001, Lines 217-236 + Report 002, Lines 843-868)
1. **Model-Checker Integration**
   - Export formulas to SMT-LIB format
   - Import validation results
   - Coordinated proof search workflow

2. **API Design**
   - Formula exchange interface
   - Serialization formats
   - Error handling

3. **Extension Points**
   - Layer 1-3 operator extensions
   - Custom operator integration
   - Semantic extension

4. **Versioning and Compatibility**
   - Semantic versioning policy
   - Deprecation timeline
   - Backward compatibility (limited)

**Rationale:** Logos is part of Logos ecosystem; clear integration protocols enable seamless cooperation with Model-Checker.

**Success Metric:** Integration examples successfully demonstrate Model-Checker coordination.

#### Document 8: Revise `docs/architecture.md`

**Action Items:** (from Report 001, Lines 238-309)
1. **Remove Broken Links** (Lines 244-256)
   - Remove links to `../README.md`, `../../docs/proof-checker.md`, etc.
   - Remove links to model-builder/model-checker architecture docs
   - Remove links to Logos glossary

2. **Update Context** (Lines 258-262)
   - Frame as standalone project with optional Logos integration
   - Remove pervasive "Logos project" references
   - Update integration section to reflect Logos perspective

3. **Fix Related Documentation Section**
   - Point to local files only (`docs/tutorial.md`, `src/docs/LEAN_STYLE_GUIDE.md`)
   - Link to Logos-specific resources

4. **Keep Technical Content**
   - LEAN code examples are correct
   - TM logic specification is accurate
   - Architecture diagrams are valid

**Rationale:** Current architecture.md is copy-pasted from Logos with broken links, making it unusable for Logos development.

**Success Metric:** All links in architecture.md resolve correctly, no references to non-existent files.

#### Document 9: `docs/CONTRIBUTING.md`

**Content Structure:**
1. **Getting Started**
   - Fork and clone repository
   - Install dependencies (LEAN 4, VS Code)
   - Run tests (`lake test`)

2. **Development Workflow**
   - TDD process (RED → GREEN → REFACTOR)
   - Code style compliance (`#lint`)
   - Documentation requirements

3. **Pull Request Process**
   - Branch naming conventions
   - Commit message format
   - PR description template
   - Review checklist

4. **Code Review Checklist** (from Report 002, Lines 566-580)
   - [ ] All definitions have docstrings
   - [ ] Tests added for new features
   - [ ] No `#lint` warnings
   - [ ] Follows naming conventions
   - [ ] Line length ≤ 100 characters

5. **Community Resources**
   - Lean Zulip Chat (#lean4, #mathlib4, #logic)
   - Issue reporting
   - Feature requests

**Rationale:** Clear contribution guidelines facilitate external contributions and maintain code quality.

**Success Metric:** Contributors follow consistent workflow, PRs meet quality standards.

---

### Recommendation 3: Configure CLAUDE.md and Build Infrastructure

**Priority: CRITICAL (Phase 1)**

#### Document 10: Root-Level `CLAUDE.md`

**Content Structure:** (from Report 000, Lines 482-517)
1. **Project Overview**
   ```markdown
   # Logos

   LEAN-based formal verification system for bimodal TM logic.

   ## Quick Start
   - `lake build` - Build the project
   - `lake test` - Run test suite
   - `#lint` - Check code quality
   ```

2. **Essential Commands**
   - Build: `lake build`
   - Test: `lake test`
   - Lint: `#lint` in VS Code
   - Documentation: `lake build :docs`
   - Clean: `lake clean`

3. **Project Structure**
   ```
   Logos/
   ├── Logos.lean        # Library root
   ├── Logos/
   │   ├── Syntax/              # Formula types
   │   ├── ProofSystem/         # Axioms and rules
   │   ├── Semantics/           # Task semantics
   │   ├── Metalogic/           # Soundness/completeness
   │   ├── Theorems/            # Perpetuity principles
   │   └── Automation/          # Proof search
   ├── Examples/                # Usage examples
   ├── Tests/                   # Test suites
   ├── docs/                    # User documentation
   └── src/docs/                # Developer standards
   ```

4. **Documentation Index**
   - **START HERE for development:** `src/docs/LEAN_STYLE_GUIDE.md`
   - Code standards: `src/docs/MODULE_ORGANIZATION.md`
   - Testing: `src/docs/TESTING_STANDARDS.md`
   - User guide: `docs/TUTORIAL.md`

5. **Development Principles**
   - **TDD Required:** Write tests before implementation
   - **Fail-Fast:** Clear error messages, no silent failures
   - **Documentation Required:** Every public definition needs docstring
   - **Lint Compliance:** All code must pass `#lint`

6. **Key Packages**
   - `Logos.Syntax` - Formula construction and parsing
   - `Logos.ProofSystem` - Axioms, rules, derivations
   - `Logos.Semantics` - Task frames and truth evaluation
   - `Logos.Metalogic` - Soundness and completeness proofs

7. **Testing Architecture**
   - Unit tests: `Tests/Unit/`
   - Integration tests: `Tests/Integration/`
   - Example tests: `Tests/Examples/`
   - Metalogic tests: `Tests/Metalogic/`

8. **Quality Standards**
   - Code coverage: ≥85% overall, ≥90% critical paths
   - Lint compliance: 100% (zero warnings)
   - Documentation: 100% (all public definitions)
   - Performance: <1s for standard theorem proving

9. **Common Tasks**
   - **Add new axiom:** Implement in `ProofSystem/Axioms.lean`, test in `Tests/Unit/test_axioms.lean`, document in module docstring
   - **Create custom tactic:** Implement in `Automation/`, test in `Tests/Unit/`, add usage example to `docs/EXAMPLES.md`
   - **Add perpetuity theorem:** Prove in `Theorems/Perpetuity.lean`, test derivation, add to examples

10. **Notes for Claude Code**
    - LEAN 4 syntax is strict; always verify code compiles with `lake build`
    - Use `#check` and `#eval` for inline verification
    - Refer to `src/docs/LEAN_STYLE_GUIDE.md` for naming conventions
    - All changes require tests (TDD enforced)
    - Check `#lint` before committing

**Rationale:** CLAUDE.md provides essential context for Claude Code to assist effectively with LEAN development, following Anthropic's best practices.

**Success Metric:** Claude Code can successfully navigate project structure and follow coding standards without additional prompting.

#### Document 11: `lakefile.toml` Configuration

**Content Structure:** (from Report 002, Lines 126-157)
```toml
name = "Logos"
version = "0.1.0"
description = "LEAN-based formal verification for bimodal TM logic"
keywords = ["modal-logic", "temporal-logic", "proof-assistant", "formal-verification"]
license = "Apache-2.0"

[[lean_lib]]
name = "Logos"
roots = ["Logos"]
globs = ["."]

# Build configuration
buildType = "debug"          # Use "release" for production
precompileModules = true     # Faster metaprogram evaluation

# Test configuration
[[lean_exe]]
name = "tests"
root = "Tests/Main.lean"

# Lint configuration
[[lean_exe]]
name = "lint"
root = "Scripts/Lint.lean"
```

**Additional Files:**
- `lean-toolchain`: Pin LEAN version (e.g., `leanprover/lean4:v4.26.0`)
- `.gitignore`: Exclude `.lake/`, `build/`, `*.olean`

**Rationale:** Lake configuration is mandatory for LEAN 4 projects; proper setup enables reproducible builds and testing.

**Success Metric:** `lake build`, `lake test`, and `lake lint` execute successfully.

#### Document 12: `.github/workflows/ci.yml` CI/CD Pipeline

**Content Structure:** (from Report 002, Lines 479-495)
```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: leanprover/lean4-action@v1
        with:
          lean-version: 'leanprover/lean4:v4.26.0'
      - name: Build
        run: lake build
      - name: Test
        run: lake test
      - name: Lint
        run: lake lint
      - name: Generate Docs
        run: lake build :docs
      - name: Deploy Docs
        uses: peaceiris/actions-gh-pages@v3
        if: github.ref == 'refs/heads/main'
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./.lake/build/doc
```

**Rationale:** Automated CI/CD ensures code quality, catches regressions, and maintains documentation currency.

**Success Metric:** All CI checks pass on every commit, documentation auto-deploys to GitHub Pages.

---

### Recommendation 4: Populate README.md with Project Overview

**Priority: HIGH (Phase 2)**

**Content Structure:** (from Report 001, Lines 264-300)
```markdown
# Logos

A LEAN 4-based formal verification system for bimodal TM (Tense and Modality) logic.

## Overview

Logos constructs machine-checkable proofs for the Logos formal language, providing:
- Verified reasoning in bimodal TM logic
- S5 modal logic (necessity and possibility)
- Temporal logic (past and future operators)
- Soundness and completeness proofs
- Automated proof tactics and search

## Features

- **Bimodal Logic TM:** Combines S5 modal logic with temporal operators
- **Layer 0 Core:** Primitive operators (□, ◇, Past, Future) with perpetuity principles
- **Task Semantics:** World states, time, and task relations
- **Proof Automation:** Custom tactics for modal/temporal reasoning
- **Mathlib4 Compatible:** Follows LEAN 4 community standards
- **Integration Ready:** Export to SMT-LIB for Model-Checker coordination

## The Logic TM

### Core Operators
- `□φ` - Necessity (modal)
- `◇φ` - Possibility (modal)
- `Past φ` - Universal past (temporal)
- `Future φ` - Universal future (temporal)
- `always φ` - Perpetuity (past, present, future)
- `sometimes φ` - Occurrence (past, present, future)

### Axiom System
- **S5 Modal:** MT (reflexivity), M4 (transitivity), MB (symmetry)
- **Temporal:** T4, TA, TL
- **Bimodal Interaction:** MF, TF

### Perpetuity Principles
- P1: `□φ → always φ` (necessity implies perpetuity)
- P2-P6: Additional theorems linking modality and temporality

## Installation

### Requirements
- LEAN 4 (v4.26.0 or later)
- Lake package manager
- VS Code with Lean 4 extension (recommended)

### Build
```bash
git clone https://github.com/[username]/Logos.git
cd Logos
lake build
```

### Test
```bash
lake test
```

## Quick Start

```lean
import Logos

-- Define a modal formula
def φ : Formula := box (atom "p")

-- Prove MT axiom: □p → p
theorem mt_example : ⊢ φ → atom "p" := by
  modal_auto
```

## Documentation

- [Architecture](docs/architecture.md) - System design and TM logic specification
- [Tutorial](docs/TUTORIAL.md) - Getting started guide
- [Examples](docs/EXAMPLES.md) - Modal, temporal, and bimodal examples
- [API Reference](https://proofchecker.github.io/docs/) - Auto-generated documentation
- [Contributing](docs/CONTRIBUTING.md) - Contribution guidelines

## Related Projects

- [Logos](https://github.com/[username]/Logos) - Parent project (Model-Builder, Model-Checker, Proof-Checker)
- [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) - Modal logic in LEAN 4
- [Mathlib4](https://github.com/leanprover-community/mathlib4) - LEAN mathematics library

## License

Apache-2.0

## Citation

If using Logos in academic research, please cite:
```
[Citation information to be added]
```
```

**Rationale:** README.md is the entry point for all users; comprehensive overview with quick start facilitates adoption.

**Success Metric:** New users can understand project purpose and run first example within 10 minutes.

---

### Recommendation 5: Establish Quality Metrics and Maintenance Standards

**Priority: MEDIUM (Phase 3)**

Create two additional standards documents for long-term maintenance:

#### Document 13: `docs/VERSIONING.md`

**Content Structure:**
1. **Semantic Versioning Policy**
   - MAJOR: Breaking changes to public API
   - MINOR: New features, backward-compatible
   - PATCH: Bug fixes, no API changes

2. **Deprecation Timeline** (from Report 002, Lines 301-308)
   - Use `@[deprecated (since := "YYYY-MM-DD")]`
   - 6-month window before deletion
   - Document breaking changes in CHANGELOG.md

3. **Release Process**
   - Tag releases: `v0.1.0`, `v0.2.0`, `v1.0.0`
   - Update CHANGELOG.md
   - Generate release notes
   - Deploy documentation

4. **Backward Compatibility** (adapted from Report 000, Lines 23-43)
   - Limited backward compatibility (clean refactoring preferred)
   - Document breaking changes explicitly
   - Provide migration guides for major versions

**Rationale:** Clear versioning enables downstream projects to manage dependencies safely.

**Success Metric:** All releases follow semantic versioning, breaking changes documented.

#### Document 14: `src/docs/QUALITY_METRICS.md`

**Content Structure:**
1. **Code Coverage Targets** (from Report 000, Lines 334-342)
   - Overall: ≥85%
   - Critical paths (Metalogic/): ≥90%
   - Utilities (Automation/): ≥80%
   - Error handling: ≥75%

2. **Lint Compliance** (from Report 002, Lines 296-300)
   - Zero `#lint` warnings
   - `docBlame` - All definitions documented
   - `docBlameThm` - All theorems documented

3. **Documentation Completeness**
   - 100% public definitions have docstrings
   - All modules have module docstrings
   - Examples for all custom tactics
   - Tutorial covers all major features

4. **Performance Benchmarks**
   - Build time: <2 minutes for full project
   - Test execution: <30 seconds for full suite
   - Proof search: <1 second for standard theorems
   - Documentation generation: <1 minute

5. **Complexity Limits**
   - Function complexity: <50 lines
   - Module size: <1000 lines
   - Maximum nesting depth: 4 levels
   - Proof tactic count: <20 tactics per proof (use automation)

**Rationale:** Quantifiable metrics enable objective quality assessment and prevent technical debt accumulation.

**Success Metric:** All metrics achieved before v1.0.0 release, tracked in CI dashboard.

---

### Recommendation 6: Implementation Sequence

**Phase 1: Foundation (Week 1-2) - CRITICAL**
1. Create `CLAUDE.md` (Document 10)
2. Configure `lakefile.toml` and `lean-toolchain` (Document 11)
3. Set up CI/CD pipeline (Document 12)
4. Create `src/docs/LEAN_STYLE_GUIDE.md` (Document 1)
5. Create `src/docs/MODULE_ORGANIZATION.md` (Document 2)
6. Create `src/docs/TESTING_STANDARDS.md` (Document 4)
7. Populate `README.md` (Recommendation 4)
8. Set up `.gitignore` and Git workflow

**Phase 2: Development Infrastructure (Week 3-4) - HIGH**
9. Create `src/docs/TACTIC_DEVELOPMENT.md` (Document 3)
10. Create `docs/TUTORIAL.md` (Document 5)
11. Create `docs/EXAMPLES.md` (Document 6)
12. Revise `docs/architecture.md` (Document 8)
13. Create `docs/CONTRIBUTING.md` (Document 9)

**Phase 3: Integration and Maintenance (Week 5-6) - MEDIUM**
14. Create `docs/INTEGRATION.md` (Document 7)
15. Create `docs/VERSIONING.md` (Document 13)
16. Create `src/docs/QUALITY_METRICS.md` (Document 14)
17. Generate initial API reference documentation
18. Set up GitHub Pages for documentation hosting

**Rationale:** Phased approach ensures critical foundations are in place before implementation begins, while allowing documentation to evolve with the codebase.

**Success Metric:** Phase 1 completed before any LEAN implementation begins; Phase 2 completed before Layer 0 implementation finished; Phase 3 completed before external release.

---

### Summary of Standards Documents

| Document | Location | Category | Priority | Purpose |
|----------|----------|----------|----------|---------|
| 1. LEAN_STYLE_GUIDE.md | src/docs/ | LEAN-Specific | CRITICAL | Code style, naming, formatting |
| 2. MODULE_ORGANIZATION.md | src/docs/ | LEAN-Specific | CRITICAL | Directory structure, dependencies |
| 3. TACTIC_DEVELOPMENT.md | src/docs/ | LEAN-Specific | HIGH | Custom tactic patterns, testing |
| 4. TESTING_STANDARDS.md | src/docs/ | Testing | CRITICAL | Test organization, coverage, CI/CD |
| 5. TUTORIAL.md | docs/ | User Documentation | HIGH | Getting started guide |
| 6. EXAMPLES.md | docs/ | User Documentation | HIGH | Usage examples |
| 7. INTEGRATION.md | docs/ | User Documentation | MEDIUM | Model-Checker integration |
| 8. architecture.md (revised) | docs/ | User Documentation | HIGH | System design specification |
| 9. CONTRIBUTING.md | docs/ | User Documentation | HIGH | Contribution guidelines |
| 10. CLAUDE.md | root | Configuration | CRITICAL | Claude Code configuration |
| 11. lakefile.toml | root | Configuration | CRITICAL | LEAN build configuration |
| 12. ci.yml | .github/workflows/ | Configuration | CRITICAL | CI/CD automation |
| 13. VERSIONING.md | docs/ | Maintenance | MEDIUM | Semantic versioning policy |
| 14. QUALITY_METRICS.md | src/docs/ | Maintenance | MEDIUM | Coverage, lint, performance |

**Total:** 14 standards documents across 4 categories

## References

### Primary Research Reports

1. **Package Description Report**
   - Path: `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/001_proof_checker_package_docs/reports/001-research-the-proof-checker-package-descr.md`
   - Lines referenced: 1-328 (entire report)
   - Content: Logos overview, TM logic specification, architecture, integration requirements

2. **LEAN 4 Best Practices Report**
   - Path: `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/002_lean4_proof_checker_best_practices/reports/001-research-the-best-practices-online-for-d.md`
   - Lines referenced: 1-957 (entire report)
   - Content: LEAN 4 ecosystem, Lake configuration, Mathlib4 style guide, modal logic patterns, tactic development, testing strategies

3. **Coding Standards Report**
   - Path: `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/000_no_name_error/reports/001-i-just-created-this-proof-checker-repo-a.md`
   - Lines referenced: 1-607 (entire report)
   - Content: ModelChecker development principles, Python standards (adapted for LEAN), testing standards, CLAUDE.md best practices

### External Sources (from Report 002)

- **LEAN 4 Documentation:** https://leanprover.github.io/theorem_proving_in_lean4/
- **Mathlib4 Style Guide:** https://leanprover-community.github.io/contribute/style.html
- **FormalizedFormalLogic/Foundation:** https://github.com/FormalizedFormalLogic/Foundation
- **Lake Package Manager:** https://github.com/leanprover/lean4/blob/master/src/lake/README.md
- **Lean Zulip Chat:** https://leanprover.zulipchat.com/

### External Sources (from Report 000)

- **Anthropic Claude Code Best Practices:** https://www.anthropic.com/engineering/claude-code-best-practices
- **What's a Claude.md File?** https://apidog.com/blog/claude-md/
- **PEP 8 Style Guide:** https://peps.python.org/pep-0008/
- **Python Code Quality:** https://realpython.com/python-code-quality/

### Project Files Referenced

- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/architecture.md` (Lines 1-52164, requires revision)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md` (currently empty)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/src/docs/README.md` (currently empty)

---

*Research completed: 2025-12-01*

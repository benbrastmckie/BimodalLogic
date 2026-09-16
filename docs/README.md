# ProofChecker Documentation

Project-wide documentation hub for the ProofChecker formal verification project.

> **Project Naming**: The repository is named **BimodalLogic**, the project display name is
> **ProofChecker**, the Lake package is named **Logos** (in lakefile.toml), and the primary
> Lean library namespace is **Bimodal** (in `FormalSystem/`). These names serve different
> purposes: the repository name reflects the GitHub URL, the display name appears in user-facing
> documentation, the package name is used by Lake for dependency resolution, and the library
> namespace is used in Lean import statements.

## Framework Overview

ProofChecker implements TM bimodal logic (Tense and Modality) in Lean 4 with verified soundness and completeness proofs.

**Bimodal** is the production-ready implementation providing a complete propositional
intensional logic combining S5 modal and linear temporal operators. The implementation includes
fully verified soundness, weak completeness for all four frame classes, and the deduction
theorem. A tableau decision procedure is implemented with its **sound direction** proved; the
completeness direction is open. *Strong* completeness (arbitrary infinite premise sets) is not
available uniformly -- see
[known-limitations.md](project-info/known-limitations.md).

**Getting Started**: See the [Bimodal documentation](.) for tutorials, examples, and reference materials.

## System Names and the Paper's Mapping

Two families of system name appear in this repository, and only one of them is the paper's. The
full statement lives in the module docstring of
[FormalSystem/Metalogic/Conservativity.lean](../FormalSystem/Metalogic/Conservativity.lean); the
short version:

| Repository | Language | Paper |
|------------|----------|-------|
| `TM` | `L`, with `S` and `U` primitive (`FormalSystem/ProofSystem/`) | the paper's `TM` — the same system under the same name |
| `TM_z`, `TM_d`, `TM_r` | the same, plus the discrete / dense / dense-and-complete axioms | the paper's `TM_z`, `TM_d`, `TM_r` |
| `BX_z`, `BX_d`, `BX_r` | the Burgess–Xu tense cores underneath those | the paper's `BX_z`, `BX_d`, `BX_r` |
| `TM⁻` | `L⁻`, the Past/Future language with `H` and `G` primitive (`FormalSystem/Syntax/MinusLanguage/`) | none — the H/G fragment was withdrawn from the paper |
| `TM⁻_z`, `TM⁻_d`, `TM⁻_r` | the same, plus `DF` / `DN` / `DN` and `CO` | none |
| `TM⁺` | `L⁺`, `L` plus the stability modal `⊡` (`FormalSystem/Syntax/PlusLanguage/`) | none — `L⁺` is the ⊡-only fragment of the paper's `𝓛⋆`, for which the paper supplies no logic |

The subscripts on the `TM` side name the class each system is complete over: `z` for `ℤ`-time,
`d` for the dense task frames, `r` for `ℝ`-time — the dense and Dedekind-complete orders. `BX_r`
extends `BX_d` by `PU` and `SEP`, with `CO` a derived theorem rather than an axiom, which is how
this repository arranges its Dedekind-class derivations too.

On the `TM⁻` side the same three subscripts are Lean-only labels. The paper names no Past/Future
system, so `TM⁻_z` should not be read as one; the subscripts were chosen only to run parallel to
the `TM` side and to the frame-class tags `.ZTime`, `.Dense` and `.RTime`.

The `⁻` and `⁺` superscripts are what separate this repository's own systems from the paper's,
and they are load-bearing throughout `FormalSystem/Metalogic/Conservativity/`. The full
four-language table — L⁻, L, L⁺, L⋆, their operators, their logics and their Lean homes — is in
[the repository README](../README.md); it is stated once there and not restated here. Earlier
revisions of this documentation used `_f` where `_z` now stands, and used two names, `_c` and
`_dc`, where a single `_r` now stands; those subscripts have been retired everywhere. Earlier
revisions also called the since/until system `TM⁺` and the H/G system `TM`; those names have
been retired too, in favour of the paper's own `TM` for the since/until system.

## Theory-Specific Documentation

For documentation specific to the bimodal logic theory, see:

| Theory | Status | Description | Documentation |
|--------|--------|-------------|---------------|
| **Bimodal** | Complete | Propositional intensional logic with soundness/completeness proofs | [docs/](.) |

### Quick Access by Need

| Need | Bimodal (Complete) |
|------|-------------------|
| Quick start | [Quick Start](user-guide/quickstart.md) |
| Axiom reference | [Axioms](reference/axiom-reference.md) |
| Implementation status | [Status](project-info/implementation-status.md) |
| Known limitations | [Limitations](project-info/known-limitations.md) |

**Theory research**: [research/BIMODAL_LOGIC.md](research/BIMODAL_LOGIC.md) - Bimodal logic foundations and theory

## Project-Wide Documentation

This directory contains documentation applicable to **all theories**:

- **Development standards** - Apply to all Lean code
- **Installation guides** - Project-wide setup
- **Architecture decisions** - Cross-cutting concerns
- **Research methodology** - Shared approaches

## Documentation Organization

### Installation/

Setup and configuration guides:

- [README.md](installation/README.md) - Installation overview and quick start
- [BASIC_INSTALLATION.md](installation/BASIC_INSTALLATION.md) - Installation guide (elan, Lean, Lake, Mathlib)

**Audience**: New users, contributors setting up development environment

### user-guide/

Project-wide user documentation:

- [README.md](user-guide/README.md) - Directory overview
- [INTEGRATION.md](user-guide/INTEGRATION.md) - Integration with model checkers and other tools
- [MCP_INTEGRATION.md](user-guide/MCP_INTEGRATION.md) - MCP server integration (advanced)

> **Theory-specific guides**: See [docs/user-guide/](user-guide)
> for tutorials, examples, and architecture documentation.

**Audience**: Users integrating ProofChecker with external tools

### research/

Project-wide research documents:

- [README.md](research/README.md) - Research documentation overview
- [BIMODAL_LOGIC.md](research/BIMODAL_LOGIC.md) - Bimodal Logic foundations
- [NONCOMPUTABLE.md](research/NONCOMPUTABLE.md) - The `noncomputable` keyword: comprehensive analysis
- [DEDUCTION_THEOREM_NECESSITY.md](research/DEDUCTION_THEOREM_NECESSITY.md) - Why the deduction theorem must be noncomputable
- [DUAL_VERIFICATION.md](research/DUAL_VERIFICATION.md) - RL training architecture design
- [PROOF_LIBRARY_DESIGN.md](research/PROOF_LIBRARY_DESIGN.md) - Theorem caching design
- [PROPERTY_BASED_TESTING_LEAN4.md](research/PROPERTY_BASED_TESTING_LEAN4.md) - Property-based testing research
- [competitive-landscape.md](research/competitive-landscape.md) - BMLogic-Bench competitive analysis (13-dimension matrix, 12 benchmarks)

> **Theory-specific research**: See [docs/research/](research).

**Audience**: Researchers, architects

### project-info/

Project-wide status and tracking:

- [README.md](project-info/README.md) - Directory overview
- [FEATURE_REGISTRY.md](project-info/FEATURE_REGISTRY.md) - Feature tracking and capabilities
- [known-limitations.md](project-info/known-limitations.md) - The genuine open items: strong completeness, the decision procedure's completeness direction, discrete non-compactness, conservativity, independence
- [implementation-status.md](project-info/implementation-status.md) - Module-by-module status tracking with verification commands
- [MAINTENANCE.md](project-info/MAINTENANCE.md) - TODO management workflow

> **Theory-specific status**: See theory project-info directories for implementation status.

**Audience**: Contributors, maintainers

### development/

Developer standards, conventions, and contribution workflow:

- [README.md](development/README.md) - Directory overview and reading order
- [BENCHMARKING_GUIDE.md](development/BENCHMARKING_GUIDE.md) - Performance benchmarking and profiling guide
- [CI_CD_PROCESS.md](development/CI_CD_PROCESS.md) - Continuous integration and deployment pipeline
- [CONTRIBUTING.md](development/CONTRIBUTING.md) - Contribution guidelines and workflow
- [DIRECTORY_README_STANDARD.md](development/DIRECTORY_README_STANDARD.md) - Directory-level documentation standard
- [DOC_QUALITY_CHECKLIST.md](development/DOC_QUALITY_CHECKLIST.md) - Documentation quality assurance checklist
- [LATEX_STANDARDS.md](development/LATEX_STANDARDS.md) - LaTeX documentation standards and conventions
- [LEAN_STYLE_GUIDE.md](development/LEAN_STYLE_GUIDE.md) - Coding conventions and documentation requirements
- [METAPROGRAMMING_GUIDE.md](development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming fundamentals for tactics
- [MODULE_ORGANIZATION.md](development/MODULE_ORGANIZATION.md) - Directory structure and namespace patterns
- [NONCOMPUTABLE_GUIDE.md](development/NONCOMPUTABLE_GUIDE.md) - Handling noncomputable definitions and Classical logic
- [PHASED_IMPLEMENTATION.md](development/PHASED_IMPLEMENTATION.md) - Implementation roadmap with execution waves
- [PROPERTY_TESTING_GUIDE.md](development/PROPERTY_TESTING_GUIDE.md) - Property-based testing patterns and Plausible usage
- [QUALITY_METRICS.md](development/QUALITY_METRICS.md) - Quality targets and performance benchmarks
- [TESTING_STANDARDS.md](development/TESTING_STANDARDS.md) - Test requirements and coverage targets
- [VERSIONING.md](development/VERSIONING.md) - Semantic versioning policy

**Audience**: Developers, contributors

### reference/

Project-wide reference materials:

- [README.md](reference/README.md) - Directory overview and quick lookup guide
- [API_REFERENCE.md](reference/API_REFERENCE.md) - API documentation

> **Theory-specific reference**: See [docs/reference/](reference)
> for TM operators and axioms.

**Audience**: All users looking up APIs

### architecture/

Architectural Decision Records (ADRs) and system architecture documentation:

- [README.md](architecture/README.md) - ADR catalog and guidance
- [ADR-001-Classical-Logic-Noncomputable.md](architecture/ADR-001-Classical-Logic-Noncomputable.md) - Classical logic for metalogic
- [ADR-004-Remove-Project-Level-State-Files.md](architecture/ADR-004-Remove-Project-Level-State-Files.md) - State file architecture
- [BFMCS_architecture.md](architecture/BFMCS_ARCHITECTURE.md) - BFMCS proof architecture (base completeness construction)

**Audience**: Architects, maintainers

## Durable Records Placement

A **durable record** is a file that live code, a script, or a gate cites and checks against — not
a task-management artifact whose lifetime is one task's. `specs/` is the ephemeral
task-management tree: task directories are renumbered by vault operations, `specs/archive/` is
gitignored, and its contents are one cleanup away from silently breaking every citer. A record
cited from live `FormalSystem/**` docstrings or checked by a script belongs under `docs/`
instead, split by genre:

- **Decision records** (a settled architectural or semantic decision, its rationale, and its
  consequences) go in [`docs/architecture/`](architecture/), listed in that directory's
  "Specification and Decision Documents" table. This is also where ADRs live; there is **no**
  `docs/decisions/` — a second location for the same genre would recreate the duplicate-authority
  problem ADRs exist to remove.
- **Reference manifests** (pinned, hash-verified source-of-truth data — e.g. a paper-anchor
  citation manifest) go in [`docs/reference/`](reference/), listed in that directory's "Records
  of Record" table.

Moving a record from `specs/` to `docs/` is not a plain rename: `docs/` sits inside several
gates' scope that `specs/**` is deliberately excluded from (slash-path resolution, relative-link
resolution, paper-anchor citation resolution, `file.lean:NNN` citation policy, and the
task-number-citation ban `no-task-references-in-deliverables.md` enforces outside `specs/**`).
Simulate the move and re-run `scripts/check-module-invariants.sh --no-build` before committing to
one, and repoint every live referrer (Lean docstrings, scripts, other docs, typst comments) in the
same change.

### training/

Training data pipeline documentation:

- [README.md](training/README.md) - Directory overview and document index
- [PIPELINE.md](training/PIPELINE.md) - Dual-signal training data pipeline reference (all 6 Lean modules, JSON schemas, [BimodalHarness](https://github.com/benbrastmckie/BimodalHarness) integration)
- [PUBLISHING_GUIDE.md](training/PUBLISHING_GUIDE.md) - Consumer quick-start and maintainer workflow for Hugging Face Hub publishing

**Audience**: ML researchers, contributors working on neural proof search

## Quick Links by Audience

### For New Users

1. [Installation](installation/README.md) - Set up ProofChecker
2. [Basic Installation](installation/BASIC_INSTALLATION.md) - Step-by-step setup guide
3. [Bimodal Tutorial](user-guide/tutorial.md) - Start writing proofs
4. [TM Architecture](user-guide/architecture.md) - Understand TM logic

### For Contributors

1. [Implementation Status](project-info/implementation-status.md) - What's implemented
2. [Contributing Guidelines](development/CONTRIBUTING.md) - How to contribute
3. [Style Guide](development/LEAN_STYLE_GUIDE.md) - Coding standards
4. [Maintenance Workflow](project-info/MAINTENANCE.md) - TODO and documentation procedures

### For Developers

1. [Testing Standards](development/TESTING_STANDARDS.md) - Test requirements
2. [Module Organization](development/MODULE_ORGANIZATION.md) - Project structure
3. [Metaprogramming Guide](development/METAPROGRAMMING_GUIDE.md) - LEAN 4 tactics
4. [Phased Implementation](development/PHASED_IMPLEMENTATION.md) - Execution roadmap
5. [Quality Metrics](development/QUALITY_METRICS.md) - Quality targets

### For Researchers

1. [Research Overview](research/README.md) - Research documentation index
2. [Bimodal Logic](research/BIMODAL_LOGIC.md) - Theoretical foundations

### Quick Reference

- [TM Operators](reference/operators.md) - Symbol notation guide

## By Use Case

### I want to understand the theory

**Start with**:
1. [Project README](../README.md) - Project overview and motivations
2. [Bimodal Architecture](user-guide/architecture.md) - The complete, verified system
3. [Bimodal Logic](research/BIMODAL_LOGIC.md) - Theoretical foundations

### I want to write proofs

**Start with Bimodal** (complete implementation):
1. [Bimodal Quick Start](user-guide/quickstart.md) - Get started
2. [Bimodal Tutorial](user-guide/tutorial.md) - Step-by-step guide
3. [LEAN Style Guide](development/LEAN_STYLE_GUIDE.md) - Coding conventions
4. [Bimodal Examples](user-guide/examples.md) - Worked examples

### I want to integrate with external tools

**Start with**:
1. [Integration Guide](user-guide/INTEGRATION.md) - Model-Checker integration
2. [MCP Integration](user-guide/MCP_INTEGRATION.md) - MCP server integration
3. [Dual Verification](research/DUAL_VERIFICATION.md) - Training architecture

### I want to contribute

**Start with**:
1. [Contributing Guide](development/CONTRIBUTING.md) - Contribution workflow
2. [Implementation Status](project-info/implementation-status.md) - What's implemented
3. [TODO.md](../specs/TODO.md) - Active tasks

## Documentation Update Workflow

When updating documentation:

1. **Theory-specific changes**: Update theory docs/ directories
   - Bimodal changes -> docs/
   - New features/tutorials -> theory user-guide/
   - Operators/axioms -> theory reference/

2. **Project-wide changes**: Update this docs/ directory
   - Installation guides -> installation/
   - Development standards -> development/
   - Architecture decisions -> architecture/

3. **Implementation changes**: Update appropriate project-info/
   - Theory status -> theory project-info/implementation-status.md
   - Project status -> docs/project-info/implementation-status.md

4. **Style/standard changes**: Update development/ standards files
   - Coding conventions -> LEAN_STYLE_GUIDE.md
   - Test patterns -> TESTING_STANDARDS.md
   - Directory structure -> MODULE_ORGANIZATION.md

5. **Cross-references**: Ensure all links remain valid
   - Check links in updated files
   - Update README.md files if structure changes
   - Run link checker if available

## Documentation Standards

All documentation files follow:

- **Line limit**: 100 characters per line
- **Markdown formatting**: Standard Markdown conventions
- **Formal symbols**: Unicode operators must use backticks (e.g., `[]`, `<>`)
- **Headings**: Use ATX-style headings (`#`, `##`, `###`)
- **Code blocks**: Always specify language (```lean, ```bash)

For detailed documentation standards, see:

- [LEAN Style Guide - Code Comments](development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols)

### Building Documentation

Generated API documentation is published by
[`.github/workflows/docs.yml.disabled`](../.github/workflows/docs.yml.disabled), which runs
`leanprover-community/docgen-action` and deploys the result to GitHub Pages. The workflow is
**currently disabled** (`docgen-action` requires a `lakefile.toml`), so it does not run on push
and the published site is not being refreshed. The docstrings in the tree are the source; `references.bib` at the repository root
supplies the bibliography, so a `[key]` citation in a `## References` block renders as a real
reference rather than a bare surname and year.

**There is deliberately no `doc-gen4` entry in `lakefile.lean` or `lake-manifest.json`, and
none should be added.** The action supplies doc-gen4 itself. Declaring it as a package
dependency would put it into every contributor's `lake build` for the sake of a job that only
ever runs in CI. `lake build :docs` therefore still does not exist and is still not the way to
build these pages; there is no local build target at all.

**One-time manual step, and the docs will not appear until it is done.** The repository's Pages
source must be set to **GitHub Actions** (Settings → Pages → Build and deployment → Source). A
workflow cannot set this for itself. Until it is set, the workflow runs and the deploy step has
nowhere to publish.

The workflow passes `build-page: false`. That is load-bearing rather than a default restated:
the action's `homepage` input defaults to `docs`, and it expects that directory to be a Jekyll
site into whose `docs/docs/` subdirectory the API pages are placed. This `docs/` tree is ~100
hand-written markdown files with no `_config.yml`. If a landing page is ever wanted, the route
is `homepage: website` pointing at a real Jekyll site in a new directory — never this one.

[`reference/API_REFERENCE.md`](reference/API_REFERENCE.md) remains the hand-written reading
guide and [`theorem-index.md`](theorem-index.md) the per-theorem ledger; the generated site
complements them rather than replacing them.

## External Resources

- [LEAN 4 Manual](https://lean-lang.org/lean4/doc/) - Official LEAN 4 documentation
- [Mathlib4 Docs](https://leanprover-community.github.io/mathlib4_docs/) - Mathlib4 API
- [Lean Zulip](https://leanprover.zulipchat.com/) - Community chat

## Related Repositories

- [BimodalHarness](https://github.com/benbrastmckie/BimodalHarness) - AlphaZero-style neural proof search training
- [Model-Checker](https://github.com/benbrastmckie/ModelChecker) - Semantic verification

---

_Last updated: March 2026_

---

## Merged from the Lean source tree

The `docs/` tree was folded into this one. Previously the repository
carried two parallel `docs/` trees, and this file cross-linked into the other via
`docs/...` — an incoherence that the merge removes. The index below
came from the source-tree copy of this file; its entries now refer to files in this
directory.

Theory-specific documentation hub for the Bimodal TM (Tense and Modality) logic implementation.

> **Note**: For project-wide documentation applicable to all theories, see
> [docs/](README.md).

## About Bimodal Logic

Bimodal is a **propositional intensional logic** with:

- **Semantic primitives**: World-states in a Kripke-style framework
- **Interpretation**: Sentence letters are interpreted by sets of world-states
- **Logical level**: Propositional (zeroth-order)

For comparison with the planned Logos hyperintensional logic, see
[bimodal-logic.md](research/BIMODAL_LOGIC.md).

## Documentation Organization

Documentation is organized into four categories:

### user-guide/

User-facing documentation for working with Bimodal:

- [README.md](user-guide/README.md) - Directory overview and reading order
- [quickstart.md](user-guide/quickstart.md) - Getting started with Bimodal proofs
- [proof-patterns.md](user-guide/proof-patterns.md) - Common proof patterns and strategies
- [architecture.md](user-guide/architecture.md) - TM logic specification and system design
- [tutorial.md](user-guide/tutorial.md) - Step-by-step tutorial
- [examples.md](user-guide/examples.md) - Usage examples and proof patterns
- [tactic-development.md](user-guide/tactic-development.md) - Custom tactic development

**Audience**: Users of the library, learners

### reference/

Reference materials for Bimodal logic:

- [README.md](reference/README.md) - Directory overview and quick lookup guide
- [axiom-reference.md](reference/axiom-reference.md) - Complete axiom schemas with examples
- [tactic-reference.md](reference/tactic-reference.md) - Bimodal-specific tactic usage
- [operators.md](reference/operators.md) - TM operator reference and Unicode notation

**Audience**: All users

### research/

Research and design documents for Bimodal proof automation:

- [README.md](research/README.md) - Research overview
- [modal-temporal-proof-search.md](research/modal-temporal-proof-search.md) - Proof search architecture
- [proof-search-automation.md](research/proof-search-automation.md) - Automation strategies
- [temporal-logic-automation.md](research/temporal-logic-automation.md) - Temporal tactics
- [leansearch-api-specification.md](research/leansearch-api-specification.md) - LeanSearch API
- [leansearch-best-first-search.md](research/leansearch-best-first-search.md) - Best-first search
- [leansearch-priority-queue.md](research/leansearch-priority-queue.md) - Priority queue design
- [leansearch-proof-caching-memoization.md](research/leansearch-proof-caching-memoization.md) - Caching

**Audience**: Researchers, contributors

### project-info/

Bimodal-specific project status:

- [README.md](project-info/README.md) - Directory overview
- [implementation-status.md](project-info/implementation-status.md) - Bimodal module status
- [known-limitations.md](project-info/known-limitations.md) - MVP limitations with workarounds
- [tactic-registry.md](project-info/tactic-registry.md) - Tactic implementation status

**Audience**: Contributors, maintainers

## Quick Links

Most-referenced documents:

- [Quick Start](user-guide/quickstart.md) - Get started quickly
- [Tutorial](user-guide/tutorial.md) - Step-by-step guide
- [Architecture](user-guide/architecture.md) - TM logic specification
- [Axiom Reference](reference/axiom-reference.md) - Axiom schemas
- [Operators](reference/operators.md) - Operator reference
- [Implementation Status](project-info/implementation-status.md) - Current status
- [Known Limitations](project-info/known-limitations.md) - MVP limitations
- [Performance Targets](project-info/performance-targets.md) - Benchmark baselines

## Relationship to Project Documentation

**Bimodal-Specific**:
- [quickstart](user-guide/quickstart.md) - Getting started with Bimodal
- [tutorial](user-guide/tutorial.md) - Step-by-step tutorial
- [architecture](user-guide/architecture.md) - TM logic specification
- [examples](user-guide/examples.md) - Usage examples
- [tactic-development](user-guide/tactic-development.md) - Custom tactics
- [axiom-reference](reference/axiom-reference.md) - TM axiom schemas
- [operators](reference/operators.md) - Operator reference
- [tactic-registry](project-info/tactic-registry.md) - Tactic status
- [research/](research/) - Proof search automation research

**Project-Wide** (in [docs/](.)):
- [STYLE_GUIDE](development/LEAN_STYLE_GUIDE.md) - Coding style
- [TESTING](development/TESTING_STANDARDS.md) - Test standards

## Navigation

- **Up**: [Bimodal/](../)
- **Project Documentation**: [docs/](.)
- **Theory Comparison**: [bimodal-logic.md](research/BIMODAL_LOGIC.md)

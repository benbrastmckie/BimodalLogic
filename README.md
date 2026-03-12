# Bimodal Logic: Tense and Modality (TM)

A Lean 4 implementation of bimodal logic combining S5 modal operators with linear temporal operators. This project provides a complete formal verification of the syntax, semantics, proof theory, and metalogic for TM logic, establishing **soundness, completeness, and decidability**.

**Paper**: ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025) - Compositional semantics for bimodal logics with historical modals and tense operators

**Specifications**: [BimodalReference.pdf](Theories/Bimodal/latex/BimodalReference.pdf)

**Demo**: [Demo.lean](Theories/Bimodal/Examples/Demo.lean)

---

## Overview

TM bimodal logic formalizes the deep philosophical relationship between time and possibility: the present opens onto multiple possible futures (world-histories) that share a common past. This relationship is captured through the **perpetuity principles** (P1-P6), which establish that what is necessary is perpetual and what occurs is possible.

### Key Results

| Result | Statement | Status |
|--------|-----------|--------|
| **Soundness** | `(Gamma vdash phi) to (Gamma vDash phi)` | Proven |
| **Completeness** | `valid phi to (vdash phi)` | Proven |
| **Deduction Theorem** | `((A :: Gamma) vdash B) to (Gamma vdash A to B)` | Proven |
| **Decidability** | `decide phi : DecisionResult phi` | Implemented |

### Operators

| Symbol | Lean | Reading |
|--------|------|---------|
| `Box phi` | `box phi` | necessity ("necessarily phi") |
| `Diamond phi` | `diamond phi` | possibility ("possibly phi") |
| `H phi` | `all_past phi` | "phi has always been true" |
| `G phi` | `all_future phi` | "phi will always be true" |
| `P phi` | `some_past phi` | "phi was once true" |
| `F phi` | `some_future phi` | "phi will be true" |

### Task Frame Semantics

A task frame `(W, T, R)` consists of:
- **W**: Set of world-states (metaphysically possible states)
- **T**: Set of times with linear order `<`
- **R : W -> T -> W -> Prop**: Task relation (accessibility across time)

The task relation satisfies nullity (reflexive at each time) and compositionality (forward composition), enabling evaluation of modal and temporal formulas at world-history/time pairs.

---

## The Logos Connection

Bimodal logic is a fragment of the **Logos**, a formal language of thought designed to enable AI systems to reason with mathematical certainty. The Logos provides verified synthetic reasoning data of arbitrary complexity through an extensible system of proof theory and semantics. This repository focuses specifically on the bimodal fragment, which is of independent interest due to its completeness and decidability. For more about the Logos project, see [logos-labs.ai](https://logos-labs.ai/).

---

## Installation

### Requirements

- LEAN 4 v4.14.0 or later
- Lake (included with LEAN 4)
- Git for version control
- ~5GB disk space (for Mathlib cache)

### Quick Start

**AI-Assisted (Recommended)**: Use [Claude Code](docs/installation/CLAUDE_CODE.md) for automated installation

**Manual Installation**:

```bash
# Install elan (LEAN version manager)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Clone repository
git clone https://github.com/benbrastmckie/ProofChecker.git
cd ProofChecker

# Build project (first build downloads Mathlib cache, ~30 minutes)
lake build

# Run tests
lake test
```

### Installation Guides

| Guide | Description |
|-------|-------------|
| [Claude Code](docs/installation/CLAUDE_CODE.md) | AI-assisted installation (recommended) |
| [Basic Installation](docs/installation/BASIC_INSTALLATION.md) | Manual installation steps |
| [Getting Started](docs/installation/GETTING_STARTED.md) | Terminal basics, VS Code, NeoVim setup |
| [Using Git](docs/installation/USING_GIT.md) | Git/GitHub configuration |

**For complete setup**: [Installation Overview](docs/installation/README.md)

---

## Project Structure

```
ProofChecker/
  Theories/
    Bimodal/           # TM bimodal logic implementation
      Syntax/          # Formula types and contexts
      ProofSystem/     # Axioms and derivation trees
      Semantics/       # Task frame semantics
      Metalogic/       # Soundness, completeness, decidability
      Theorems/        # Perpetuity principles and derived results
      Automation/      # Proof tactics
      Examples/        # Demo and pedagogical examples
      latex/           # BimodalReference specification document
      docs/            # Theory-specific documentation
  Tests/               # Test suites
  docs/                # Project documentation
  specs/               # Task artifacts and planning
```

---

## Documentation

### User Guides

- [Tutorial](Theories/Bimodal/docs/user-guide/TUTORIAL.md) - Getting started with bimodal proofs
- [Quick Start](Theories/Bimodal/docs/user-guide/QUICKSTART.md) - Minimal setup guide
- [Examples](Theories/Bimodal/docs/user-guide/EXAMPLES.md) - Worked examples with solutions
- [Proof Patterns](Theories/Bimodal/docs/user-guide/PROOF_PATTERNS.md) - Common proof strategies
- [Troubleshooting](Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md) - Common errors and fixes

### Reference

- [Axiom Reference](Theories/Bimodal/docs/reference/AXIOM_REFERENCE.md) - Complete axiom schemas
- [Operator Reference](Theories/Bimodal/docs/reference/OPERATORS.md) - Formal symbols
- [Tactic Reference](Theories/Bimodal/docs/reference/TACTIC_REFERENCE.md) - Custom tactic usage
- [API Reference](docs/reference/API_REFERENCE.md) - Module API documentation

### Development Guides

- [Contributing](docs/development/CONTRIBUTING.md) - Contribution guidelines
- [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Testing Standards](docs/development/TESTING_STANDARDS.md) - Test requirements
- [Module Organization](docs/development/MODULE_ORGANIZATION.md) - Project structure

### Project Information

- [Implementation Status](docs/project-info/IMPLEMENTATION_STATUS.md) - Module-by-module status
- [Known Limitations](Theories/Bimodal/docs/project-info/KNOWN_LIMITATIONS.md) - Gaps and workarounds
- [Sorry Registry](docs/project-info/SORRY_REGISTRY.md) - Technical debt tracking

### Research

- [Bimodal Logic](docs/research/bimodal-logic.md) - Theoretical foundations
- [Dual Verification](docs/research/dual-verification.md) - RL training architecture
- [Proof Library Design](docs/research/proof-library-design.md) - Theorem caching

---

## Implementation Status

Bimodal is **production-ready** with complete metalogic verification.

| Layer | Component | Status |
|-------|-----------|--------|
| 0 | Syntax | Complete |
| 1 | ProofSystem | Complete (14 axioms, 7 rules) |
| 2 | Semantics | Complete (TaskFrame, TaskModel, Truth) |
| 3 | Metalogic | **Complete** (Soundness, Completeness, Deduction, Decidability) |
| 4 | Theorems | Complete (P1-P6 perpetuity principles) |
| 5 | Automation | Partial |

**For detailed status**: [Implementation Status](docs/project-info/IMPLEMENTATION_STATUS.md) | [Bimodal Status](Theories/Bimodal/docs/project-info/IMPLEMENTATION_STATUS.md)

---

## Theoretical Foundations

### ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025)

Compositional semantics drawing on non-deterministic dynamical systems theories to provide an intensional semantics for bimodal logics with historical modals and tense operators. Complete implementation in the `Semantics/` package (TaskFrame, WorldHistory, TaskModel, Truth evaluation).

### ["Counterfactual Worlds"](https://link.springer.com/article/10.1007/s10992-025-09793-8) (Brast-McKie 2025)

Hyperintensional semantics for counterfactual conditionals distinguishing necessarily equivalent antecedents. Foundation for planned explanatory layer extensions.

### ["Identity and Aboutness"](https://link.springer.com/article/10.1007/s10992-021-09612-w) (Brast-McKie 2021)

State-based semantics using verifier/falsifier pairs to capture fine-grained propositional content. Theoretical foundation for constitutive explanatory reasoning.

---

## Related Projects

- **[ModelChecker](https://github.com/benbrastmckie/ModelChecker)** - Python/Z3 implementation of Logos semantic theory for countermodel generation. Together with ProofChecker, forms the dual verification architecture.

---

## Citation

If you use this project in your research, please cite:

```bibtex
@software{proofchecker2025,
  title = {ProofChecker: LEAN 4 Implementation of Bimodal Logic TM},
  author = {Brast-McKie, Benjamin},
  year = {2025},
  url = {https://github.com/benbrastmckie/ProofChecker}
}
```

---

## License

This project is licensed under GPL-3.0. See [LICENSE](LICENSE) for details.

---

## Contributing

Contributions welcome! See [Contributing Guide](docs/development/CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Install LEAN 4
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Build and test
git clone https://github.com/benbrastmckie/ProofChecker.git
cd ProofChecker
lake build
lake test
```

### Directory Convention

- **PascalCase**: LEAN source directories (`Theories/`, `Tests/`)
- **lowercase**: Non-code directories (`docs/`, `scripts/`, `specs/`)

See [Contributing Guide](docs/development/CONTRIBUTING.md) for details.

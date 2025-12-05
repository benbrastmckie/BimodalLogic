# Logos: LEAN 4 Proof System for Bimodal Logic TM

Logos is a LEAN 4 implementation of an axiomatic proof system for the bimodal logic TM (Tense and Modality) with task semantics. It combines syntactic verification (LEAN 4 proofs) with semantic verification (Z3-based Model-Checker) to generate unlimited clean training data for AI systems learning verified reasoning, without human annotation.

**Core Innovation**: Dual verification architecture provides both positive training signals (proof receipts for valid inferences) and corrective training signals (counterexamples for invalid inferences), enabling scalable oversight through computational verification rather than human labor.

## Table of Contents

**Architecture**
- [Layered Architecture](#layered-architecture)
- [Core Layer (TM Logic)](#core-layer-tm-logic)
- [Dual Verification](#dual-verification)

**Status & Usage**
- [Implementation Status](#implementation-status)
- [Installation](#installation)
- [Documentation](#documentation)

**Reference**
- [Citation](#citation)
- [License](#license)
- [Contributing](#contributing)

---

## Layered Architecture

Logos implements a layered operator architecture supporting progressive extensibility. All layers share task semantics where possible worlds are functions from times to world-states constrained by task relations.

| Layer | Operators | Status |
|-------|-----------|--------|
| **Core** | Extensional, modal, temporal | Complete (MVP) |
| **Explanatory** | Counterfactual, causal, constitutive | Planned |
| **Epistemic** | Belief, probability, indicative | Planned |
| **Normative** | Deontic, agential, preferential | Planned |

**See also**: [Methodology](Documentation/UserGuide/METHODOLOGY.md) | [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md)

---

## Core Layer (TM Logic)

The Core Layer implements TM (Tense and Modality) - a bimodal logic combining S5 modal logic (metaphysical necessity/possibility) with linear temporal logic (past/future operators).

### Operators

| Category | Operators | Meaning |
|----------|-----------|---------|
| **Extensional** | `¬`, `∧`, `∨`, `→`, `↔`, `⊥`, `⊤` | Boolean connectives |
| **Modal** | `□` (necessity), `◇` (possibility) | S5 metaphysical modality |
| **Temporal** | `H` (always past), `G` (always future), `P` (sometime past), `F` (sometime future) | Linear temporal operators |
| **Bimodal** | `△` (always/henceforth), `▽` (sometimes/eventually) | Modal-temporal combinations |

**For operator details**: [Operators Glossary](Documentation/Reference/OPERATORS.md) | [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md)

### Axioms

**S5 Modal Axioms**:
- MT: `□φ → φ` (necessity implies actuality)
- M4: `□φ → □□φ` (necessity iterates)
- MB: `φ → □◇φ` (actuality implies necessary possibility)

**Temporal Axioms**:
- T4: `Gφ → GGφ` (future is transitive)
- TA: `φ → GPφ` (present becomes past)
- TL: `△φ → GPφ` (perpetuity implies past occurrence)

**Bimodal Interaction**:
- MF: `□φ → □Gφ` (necessity persists forward)
- TF: `□φ → G□φ` (necessity is temporally stable)

**For axiom proofs**: [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md)

### Perpetuity Principles

Six theorems connecting modal and temporal operators:

- **P1**: `□φ → △φ` (necessary truths are perpetual)
- **P2**: `▽φ → ◇φ` (occurrence implies possibility)
- **P3**: `□φ → □△φ` (necessity of perpetuity)
- **P4**: `◇▽φ → ◇φ` (possible occurrence implies possibility)
- **P5**: `◇▽φ → △◇φ` (persistent possibility)
- **P6**: `▽□φ → □△φ` (occurrent necessity is perpetual)

**For formal proofs**: [Perpetuity.lean](Logos/Theorems/Perpetuity.lean)

---

## Dual Verification

Logos combines syntactic verification (proof construction) with semantic verification (model checking) to create comprehensive training signals.

### Architecture

| Component | Role | Output |
|-----------|------|--------|
| **LEAN 4 Proof System** | Derives valid theorems from TM axioms | Proof receipts (positive signals) |
| **Model-Checker** (Z3) | Searches for countermodels in finite state spaces | Counterexamples (corrective signals) |

### Training Signal Generation

**Positive Signals**: LEAN 4 generates valid theorems with proof receipts providing mathematical certainty

**Corrective Signals**: Model-Checker generates counterexamples showing exactly why invalid inferences fail

**Scalability**: Both systems scale with computation, not human labor, enabling unlimited training data

**For training architecture details**: [Dual Verification Research](Documentation/Research/DUAL_VERIFICATION.md) | [Integration Guide](Documentation/UserGuide/INTEGRATION.md)

---

## Implementation Status

**MVP Completion**: Core Layer (TM Logic) complete with full soundness

**Current Status**:
- **Soundness**: Complete (8/8 axioms, 7/7 rules proven, zero sorry)
- **Semantics**: Complete (task frames, world histories, truth evaluation - zero sorry)
- **Perpetuity Principles**: All 6 available (P1-P6)
- **Automation**: Partial (4/12 tactics implemented with 50 tests)
- **Completeness**: Infrastructure only (proofs not started)

**For detailed status**: [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | [Known Limitations](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) | [TODO](TODO.md)

---

## Installation

### Requirements

- LEAN 4 v4.14.0 or later
- Lake (included with LEAN 4)
- VS Code with lean4 extension (recommended)

### Quick Start

```bash
# Clone repository
git clone https://github.com/yourusername/Logos.git
cd Logos

# Build project
lake build

# Run tests
lake test
```

**For complete setup**: [Tutorial](Documentation/UserGuide/TUTORIAL.md)

---

## Documentation

### Getting Started
- [Tutorial](Documentation/UserGuide/TUTORIAL.md) - Getting started guide
- [Examples](Documentation/UserGuide/EXAMPLES.md) - Modal, temporal, bimodal examples
- [Operators Glossary](Documentation/Reference/OPERATORS.md) - Formal symbols reference

### Core Documentation
- [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
- [Methodology](Documentation/UserGuide/METHODOLOGY.md) - Philosophical foundations
- [Integration Guide](Documentation/UserGuide/INTEGRATION.md) - Model-Checker integration

### Development
- [Contributing](Documentation/ProjectInfo/CONTRIBUTING.md) - Contribution guidelines
- [LEAN Style Guide](Documentation/Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Testing Standards](Documentation/Development/TESTING_STANDARDS.md) - Test requirements

### Research
- [Dual Verification](Documentation/Research/DUAL_VERIFICATION.md) - RL training architecture
- [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md) - Layers 1-3 specifications
- [Proof Library Design](Documentation/Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching

### Project Status
- [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status
- [Known Limitations](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) - Gaps and workarounds
- [TODO](TODO.md) - Active task tracking

---

## Citation

If you use Logos in your research, please cite:

```bibtex
@software{proofchecker2025,
  title = {Logos: LEAN 4 Proof System for Bimodal Logic TM},
  author = {Your Name},
  year = {2025},
  url = {https://github.com/yourusername/Logos}
}
```

**Theoretical Foundations**:
- Brast-McKie, B. (2025). ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) - Task semantics for TM logic

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Contributing

Contributions welcome! See [Contributing Guide](Documentation/ProjectInfo/CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Install LEAN 4
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Build and test
git clone https://github.com/yourusername/Logos.git
cd Logos
lake build
lake test
lake lint
```

---

## Related Projects

- **[Model-Checker](https://github.com/benbrastmckie/ModelChecker)** - Z3-based semantic verification (v1.2.12)
- **[LogicNotes](https://github.com/benbrastmckie/LogicNotes)** - Theoretical foundations for TM logic subsystems

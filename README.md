# Logos: A Formal Language of Thought

The **Logos** is designed to train AI systems in verified reasoning in a formal language of though that is interpreted by explicit semantic models. Including tense, modal, causal, counterfactual, epistemic, and normative operators, the Logos equips AI systems to engage in complex reasoning tasks for planning and evaluating actions.

By combining an **axiomatic proof system** implemented in LEAN 4 with a **recursive semantic theory** implemented in the [Model-Checker](https://github.com/benbrastmckie/ModelChecker), creating a dual verification architecture that generates comprehensive training signals without human annotation.

| Component | Role | Training Signal |
|-----------|------|-----------------|
| **LEAN 4 Proof System** | Derives valid theorems with machine-checkable proofs | Positive RL signal |
| **Model-Checker** | Identifies invalid inferences with explicit countermodels | Corrective RL signal |

AI reasoning in the Logos is both **verified** by proof receipts for all inferences and **interpreted** by explicit semantic models, providing **scalable oversight** for sophisticated reasoning. The Logos implements a layered operator architecture for modularity and extensibility with the Core Layer (TM bimodal logic) as the foundation for the explanatory, epistemic, and normative layers which provide important extensions.

## Table of Contents

**Overview**
- [Motivations](#motivations)

**Architecture**
- [Layered Architecture](#layered-architecture)
- [Core Layer (TM Logic)](#core-layer-tm-logic)
- [Core Capabilities](#core-capabilities)
- [Dual Verification](#dual-verification)
- [Application Domains](#application-domains)

**Status & Usage**
- [Implementation Status](#implementation-status)
- [Installation](#installation)
- [Documentation](#documentation)

**Reference**
- [Theoretical Foundations](#theoretical-foundations)
- [Citation](#citation)
- [License](#license)
- [Contributing](#contributing)

---

## Motivations

Training AI systems to reason reliably requires both positive signals (valid inferences) and corrective signals (invalid inferences with counterexamples where the premises are true and the conclusion is false). This dual verification approach offers three key advantages:

1. **Unbounded**: Infinite theorems are derivable from the axiom system
2. **Clean**: Soundness guarantees only valid inferences are derivable
3. **Justified**: LEAN 4 proofs provide verifiable receipts; Z3 countermodels refute invalid claims

Reasoning in Logos can be interpreted using the semantic clauses for the language, offering scalable transparency and oversight for sophisticated AI reasoning.

**See also**: [Dual Verification Research](Documentation/Research/DUAL_VERIFICATION.md) | [Integration Guide](Documentation/UserGuide/INTEGRATION.md) | [LogicNotes](https://github.com/benbrastmckie/LogicNotes)

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

## Core Capabilities

### 1. Transparent Reasoning Infrastructure
- **Mathematical Certainty**: LEAN 4 proof receipts provide verifiable justifications
- **Auditable Inferences**: Every reasoning step can be independently checked
- **Explicit Semantics**: Task semantic models make world states and possible temporal evolutions explicit
- **Accountability**: Formal proofs enable trustworthy AI decision-making

### 2. Self-Supervised Training Data Generation
- **Unlimited Theorems**: Systematic derivation from TM axioms generates infinite training data
- **No Human Annotation**: Proof receipts serve as training signals directly
- **Positive Reinforcement**: Valid inferences rewarded with mathematical certainty
- **Systematic Pattern Mastery**: Enables learning logical reasoning systematically

### 3. Dual Verification Architecture
- **Syntactic Proofs**: Logos derives valid theorems from TM axioms with LEAN 4 proof receipts
- **Semantic Validation**: Model-Checker tests theorems via Z3-based hyperintensional semantics
- **Complementary Signals**: Proof receipts provide positive reinforcement, counterexamples provide corrective feedback
- **Rapid Prototyping**: Model-Checker tests theorems before proof attempts, reducing wasted effort
- **Scalable Oversight**: Verification scales with computation, not human annotation

### 4. Progressive Extension Strategy
Logos's layered architecture enables incremental extension from core TM logic to explanatory, epistemic, and normative reasoning. Each extension provides independent value while building toward comprehensive AI reasoning capabilities.

**See also**: [Methodology](Documentation/UserGuide/METHODOLOGY.md) | [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md)

### 5. Theoretical Innovation
- **Task Semantics**: Compositional account of possible worlds from [Possible Worlds paper](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf)
- **Perpetuity Principles**: Novel theorems connecting modal and temporal operators
- **Hyperintensional Foundation**: Supports explanatory reasoning extensions from [recent research](https://link.springer.com/article/10.1007/s10992-025-09793-8)
- **LEAN 4 Implementation**: First complete formalization of TM bimodal logic

**For implementation details**: See [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)

---

## Dual Verification

Logos and Model-Checker form a **complementary dual verification architecture** providing comprehensive training signals for AI systems learning to reason in Logos.

### Architecture

| Component | Role | Output |
|-----------|------|--------|
| **LEAN 4 Proof System** | Derives valid theorems from TM axioms | Proof receipts (positive signals) |
| **Model-Checker** (Z3) | Searches for countermodels in finite state spaces | Counterexamples (corrective signals) |

### Logos: Syntactic Verification

**Role**: LEAN 4 proof assistant for Logos
- Derives valid theorems from TM axioms via formal proof
- Provides proof receipts with mathematical certainty
- Generates positive RL training signals (valid inferences)
- Implements task semantics for soundness/completeness theorems

**Current Status**: See [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) for detailed progress

### Model-Checker: Semantic Verification (Complementary Tool)

**Role**: Z3-based semantic verification for Logos ([v1.2.12](https://github.com/benbrastmckie/ModelChecker))
- Implements hyperintensional semantics via verifier/falsifier state pairs
- Generates counterexamples for invalid inferences
- Provides corrective RL training signals (refuting invalid reasoning)
- Enables rapid prototyping (test theorems before proof attempts)

**Integration**: Complementary semantic verification tool, not co-equal package in architecture

### Training Signal Generation

The dual verification architecture creates comprehensive learning signals without human annotation:

1. **Positive Signals**: Logos generates valid theorems with proof receipts
2. **Corrective Signals**: Model-Checker generates counterexamples for invalid inferences
3. **Scalable Oversight**: Both tools scale with computation, enabling unlimited training data
4. **Mathematical Certainty**: LEAN 4 proofs provide verifiable justifications, Z3 countermodels refute invalid claims

**For training architecture details**: [Dual Verification Research](Documentation/Research/DUAL_VERIFICATION.md) | [Integration Guide](Documentation/UserGuide/INTEGRATION.md)

---

## Application Domains

The Logos architecture enables domain-specific operator combinations, demonstrating how planned extensions can be composed for specific use cases:

### Medical Planning (Core + Explanatory + Epistemic)
- **Core operators**: Modal (`□`, `◇`) + Temporal (`G`, `F`, `H`, `P`) for treatment timelines
- **Explanatory operators**: Counterfactual (`□→`, `◇→`) for evaluating treatment strategies
- **Epistemic operators**: Probability (`Pr`), belief (`B`) for uncertainty quantification in diagnosis and prognosis
- **Example**: `Prescribe(DrugA) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ F(Occur(LiverDamage))`
  - Evaluates what would happen under Drug A prescription given current medication
  - Distinguishes necessary consequences (`□→`) from possible consequences (`◇→`)

### Legal Reasoning (Core + Epistemic + Normative)
- **Core operators**: Modal + Temporal for tracking events and beliefs across time
- **Epistemic operators**: Belief (`B`), epistemic modals (`Mi`, `Mu`) for evidence analysis
- **Normative operators**: Obligation (`O`), Permission (`P`) for legal requirements and permissions
- **Example**: Tracking how evidence reveals agent beliefs and motives, constructing narratives connecting motive to action

### Multi-Agent Coordination (Core + All Extensions)
- **Core**: Modal + Temporal for action timelines and coordination constraints
- **Explanatory**: Counterfactuals for evaluating alternative strategies
- **Epistemic**: Belief operators for modeling other agents' knowledge states
- **Normative**: Deontic operators (`O`, `P`) for obligations and permissions in negotiation

**See also**: [Methodology](Documentation/UserGuide/METHODOLOGY.md) | [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md) | [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md)

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

### Advanced Topics
- [Metaprogramming Guide](Documentation/Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming and tactic development
- [Quality Metrics](Documentation/Development/QUALITY_METRICS.md) - Quality targets and standards
- [Module Organization](Documentation/Development/MODULE_ORGANIZATION.md) - Project structure
- [Phased Implementation](Documentation/Development/PHASED_IMPLEMENTATION.md) - Wave-based implementation roadmap
- [Directory README Standard](Documentation/Development/DIRECTORY_README_STANDARD.md) - Directory-level documentation requirements
- [Documentation Quality Checklist](Documentation/Development/DOC_QUALITY_CHECKLIST.md) - Quality assurance checklist

---

## Theoretical Foundations

Logos implements formal semantics developed in recent research:

### Task Semantics for Possible Worlds
- **Paper**: ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025)
  - Compositional semantics drawing on non-deterministic dynamical systems theories
  - Complete implementation in `Semantics/` package (TaskFrame, WorldHistory, TaskModel, Truth evaluation)

### Hyperintensional Semantics Foundation
- **Papers**: ["Identity and Aboutness"](https://link.springer.com/article/10.1007/s10992-021-09612-w) (2021), ["Counterfactual Worlds"](https://link.springer.com/article/10.1007/s10992-025-09793-8) (2025)
  - State-based semantics enabling fine-grained distinctions for constitutive explanatory reasoning
  - Foundation for planned extensions (counterfactual, causal, constitutive operators)

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

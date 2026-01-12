# Logos: A Logic for Interpreted and Verified AI Reasoning

**Logos** is a formal verification framework in Lean 4 implementing hyperintensional logics for verified AI reasoning. By combining an axiomatic proof system with recursive semantics, Logos generates unlimited self-supervised training data for AI systems, providing proof receipts for valid inferences and countermodels for invalid ones without relying on human annotation.

**Formal Specifications**: [markdown](Theories/Logos/docs/research/recursive-semantics.md) | [pdf](Theories/Logos/latex/LogosReference.pdf) | [tex](Theories/Logos/latex/LogosReference.tex)

---

## Overview

The Logos theory is an extensible formal language equipped with an axiomatic proof system and recursive semantic theory. The modular architecture extends the expressive power of the language through progressive layer extensions:

- **Constitutive Foundation**: Predicates, functions, lambdas, quantifiers, extensional operators, and constitutive explanatory operators.
- **Explanatory Extension**: Modal, temporal, counterfactual, and causal operators for reasoning about past, future, contingency, and causation.
- **Epistemic Extension**: Belief, knowledge, probability, and indicative conditional operators for reasoning under uncertainty.
- **Normative Extension**: Permission, obligation, preference, and normative explanatory operators for reasoning about values and laws.
- **Spatial Extension**: Spatial relations and locations for reasoning about space.
- **Agential Extension**: Agency, action, and intention operators for multi-agent reasoning.
- **Reflection Extension**: Self-modeling and metacognitive operators for first-person reasoning about one's own beliefs, abilities, preferences, and goals.

The Constitutive Foundation and Explanatory Extension provide essential expressive resources for verified reasoning in an interpreted language. The Epistemic, Normative, and Spatial Extensions are modular plugins that can be combined in any subset. The Agential Extension requires at least one middle extension.

AI reasoning in the Logos is both **verified** by proof receipts for all inferences and **interpreted** by explicit semantic models, providing **scalable oversight** for sophisticated reasoning.

See [Theoretical Foundations](#theoretical-foundations) below and the [Reference Manual](Theories/Logos/latex/LogosReference.pdf) for further details.

## Table of Contents

**Value Proposition**
- [RL Training](#rl-training) - Dual verification for self-supervised AI learning
- [Motivations](#motivations) - Philosophical foundations for formal reasoning

**Architecture**
- [Layered Architecture](#layered-architecture) - Progressive layer system for modal-temporal logic
- [Constitutive Foundation](#constitutive-foundation) - Foundational predicates, quantifiers, and grounding
- [Application Domains](#application-domains) - Medical planning, legal reasoning, multi-agent coordination

**Status & Usage**
- [Implementation Status](#implementation-status) - Current development progress
- [Installation](#installation) - Quick start and setup guides
- [Documentation](#documentation) - User guides, development resources, research

**Reference**
- [Theoretical Foundations](#theoretical-foundations) - Academic papers underlying the semantics
- [Bimodal Theory](#bimodal-theory) - Intensional logic comparison baseline
- [Citation](#citation) - How to cite this project
- [License](#license) - GPL-3.0 License
- [Contributing](#contributing) - Guidelines for contributors

---

## RL Training

Training AI systems to reason reliably requires both positive signals (valid inferences) and corrective signals (invalid inferences with counterexamples where the premises are true and the conclusion is false). This dual verification approach offers three key advantages:

1. **Unbounded**: Infinite theorems are derivable from the axiom system
2. **Clean**: Soundness guarantees only valid inferences are derivable
3. **Justified**: LEAN 4 proofs provide verifiable receipts; Z3 countermodels refute invalid claims

By contrast, human reasoning data is limited, inconsistent, and prone to error, providing a poor training source. Beyond pattern matching, reasoning in the Logos provides proof receipts which ensure validity where the semantic theory for the Logos provide interpretability over explicit semantic models, offering scalable oversight for sophisticated forms of AI reasoning with an extensible set of operators.

| Component               | Role                                                      | Training Signal      |
| ----------------------- | --------------------------------------------------------- | -------------------- |
| **LEAN 4 Proof System** | Derives valid theorems with machine-checkable proofs      | Positive RL signal   |
| **[ModelChecker](https://github.com/benbrastmckie/ModelChecker)**       | Identifies invalid inferences with explicit countermodels | Corrective RL signal |

The [ModelChecker](https://github.com/benbrastmckie/ModelChecker) implements the same Logos semantic theory in Python/Z3, providing Z3-based countermodel generation for invalid inferences. Together, ProofChecker (LEAN) and ModelChecker (Z3) form a complete dual verification system---LEAN proves validity while Z3 finds countermodels.

**See also**: [Dual Verification Research](docs/research/dual-verification.md) | [Integration Guide](docs/user-guide/INTEGRATION.md) | [LogicNotes](https://github.com/benbrastmckie/LogicNotes)

---

## Motivations

Whereas the material sciences have devised methods for refining the raw materials of the natural world into materials fit for building, philosophical logic employs proof theory and model theory (semantics) to engineer formal languages that are fit for theoretical application. Rather than attempting to describe the idiosyncrasies of natural language, stipulating an axiomatic proof system and recursive semantic theory for formal languages provides a well established methodology for engineering the concepts needed for a specific application.

The Logos is an extensible formal language consisting of the logical operators needed for planning and evaluating complex actions in coordination with other agents under the conditions of uncertainty. Whereas the tense operators provide resources for reasoning about the past and future in a given history, the historical modal operators provide resources for reasoning about different possible futures (world-histories). Including tense and historical modal operators in a common language provides the conceptual resources for reasoning about future contingency, quantifying over the possible futures that could transpire from the present moment.

Constructing and evaluating plans amounts to identifying and ranking histories that proceed from the present moment into the anticipated future. The expected value of a plan is a function of its projected value, likelihood of success, and the value of counterfactual alternatives were the plan to fail along its course. Accordingly, robust planning requires counterfactual scrutiny, identifying potential fail points by evaluating the expected cost of the counterfactual histories that proceed from each potential fail point. Rather than relying on human intuition to estimate likely fail points or to rank alternatives, training AI systems to rigorously construct, counterfactually evaluate, and rank plans based on expected outcomes provides an invaluable resource for assisting human agents in effectively navigating future contingency under conditions of uncertainty and high complexity.

In addition to tense, historical modal, and counterfactual operators, effective planning under natural conditions also requires constitutive operators for reasoning about constitution, causal operators for reasoning about causation, epistemic operators for reasoning about belief, likelihoods, and indicative conditionals, and normative operators for reasoning about imperatives and preferences. Accordingly both the proof theory and semantics for the Logos are implemented in layers in order to accommodate an extensible range of operators. The layer architecture enables applications to import precisely the operator combinations needed for a given domain without carrying unused overhead.

**See also**: [Conceptual Engineering](Theories/Logos/docs/research/conceptual-engineering.md) | [Layer Extensions](Theories/Logos/docs/research/layer-extensions.md)

---

## Application Domains

The Logos architecture enables domain-specific operator combinations, demonstrating how planned extensions can be composed for specific use cases:

### Medical Planning (Constitutive + Explanatory + Epistemic)

- **Constitutive operators**: Predicates, functions, quantifiers for representing medical facts and relationships
- **Explanatory operators**: Modal (`□`, `◇`) + Temporal (`G`, `F`, `H`, `P`) for treatment timelines, Counterfactual (`□→`, `◇→`) for evaluating treatment strategies
- **Epistemic operators**: Probability (`Pr`), belief (`B`) for uncertainty quantification in diagnosis and prognosis
- **Example**: `Prescribe(DrugA) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ F(Occur(LiverDamage))`
  - Evaluates what would happen under Drug A prescription given current medication
  - Distinguishes necessary consequences (`□→`) from possible consequences (`◇→`)

### Legal Reasoning (Constitutive + Explanatory + Epistemic + Normative)

- **Constitutive operators**: Predicates and functions for representing legal facts and evidence
- **Explanatory operators**: Modal + Temporal for tracking events and beliefs across time
- **Epistemic operators**: Belief (`B`), epistemic modals (`Mi`, `Mu`) for evidence analysis
- **Normative operators**: Obligation (`O`), Permission (`P`) for legal requirements and permissions
- **Example**: Tracking how evidence reveals agent beliefs and motives, constructing narratives connecting motive to action

### Multi-Agent Coordination (All Layers)

- **Constitutive**: Predicates and functions for representing agent properties and relationships
- **Explanatory**: Modal + Temporal for action timelines and coordination constraints, Counterfactuals for evaluating alternative strategies
- **Epistemic**: Belief operators for modeling other agents' knowledge states
- **Normative**: Deontic operators (`O`, `P`) for obligations and permissions in negotiation

**See also**: [Methodology](docs/user-guide/METHODOLOGY.md) | [Layer Extensions](Theories/Logos/docs/research/layer-extensions.md) | [Architecture](docs/user-guide/ARCHITECTURE.md)

---

## Implementation Status

The Logos methodology comprises three components: (1) an **axiomatic proof theory** for deriving valid inferences, (2) a **recursive semantic theory** for interpreting formulas in explicit models, and (3) a **metalogic** establishing the soundness and completeness of the proof theory over the semantics.

**For detailed status**: [Implementation Status](docs/project-info/IMPLEMENTATION_STATUS.md) | [LEAN Registry](docs/project-info/SORRY_REGISTRY.md) | [TODO](TODO.md)

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
# Install elan (Lean version manager)
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

## Documentation

### User Guides

Getting started and working with Logos:

- [Tutorial](docs/user-guide/TUTORIAL.md) - Getting started guide
- [Examples](docs/user-guide/EXAMPLES.md) - Modal, temporal, bimodal examples
- [Architecture Guide](docs/user-guide/ARCHITECTURE.md) - TM logic specification
- [Methodology](docs/user-guide/METHODOLOGY.md) - Philosophical foundations
- [Integration Guide](docs/user-guide/INTEGRATION.md) - Model-Checker integration
- [Tactic Development](docs/user-guide/TACTIC_DEVELOPMENT.md) - Custom tactic development

### Development Guides

Contributing and extending Logos:

- [Contributing](docs/development/CONTRIBUTING.md) - Contribution guidelines
- [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Testing Standards](docs/development/TESTING_STANDARDS.md) - Test requirements
- [Metaprogramming Guide](docs/development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming
- [Module Organization](docs/development/MODULE_ORGANIZATION.md) - Project structure
- [Quality Metrics](docs/development/QUALITY_METRICS.md) - Quality targets
- [Phased Implementation](docs/development/PHASED_IMPLEMENTATION.md) - Implementation roadmap
- [Directory README Standard](docs/development/DIRECTORY_README_STANDARD.md) - Documentation requirements
- [Documentation Quality Checklist](docs/development/DOC_QUALITY_CHECKLIST.md) - Quality assurance

### Project Information

Current status and tracking:

- [Implementation Status](docs/project-info/IMPLEMENTATION_STATUS.md) - Module-by-module status
- [Known Limitations](docs/project-info/IMPLEMENTATION_STATUS.md#known-limitations) - Gaps and workarounds
- [Sorry Registry](docs/project-info/SORRY_REGISTRY.md) - Technical debt tracking
- [Tactic Registry](docs/project-info/TACTIC_REGISTRY.md) - Tactic implementation status
- [Maintenance](docs/project-info/MAINTENANCE.md) - TODO management workflow
- [TODO](TODO.md) - Active task tracking

### Research

Vision and planned architecture:

- [Research Overview](docs/research/README.md) - Research documentation index
- [Dual Verification](docs/research/dual-verification.md) - RL training architecture
- [Layer Extensions](Theories/Logos/docs/research/layer-extensions.md) - Layers 1-3 specifications
- [Proof Library Design](docs/research/proof-library-design.md) - Theorem caching
- [Conceptual Engineering](Theories/Logos/docs/research/conceptual-engineering.md) - Philosophical methodology

### Reference

- [Documentation Hub](docs/README.md) - Complete documentation index
- [Bimodal Operators](Bimodal/docs/reference/OPERATORS.md) - Formal symbols reference
- [Logos Glossary](Logos/docs/reference/GLOSSARY.md) - Key concepts and definitions

---

## Theoretical Foundations

Logos implements formal semantics developed in recent research:

### ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025)

  - Compositional semantics drawing on non-deterministic dynamical systems theories to provide an intensional semantics for bimodal logics with historical modals and tense operators
  - Complete implementation in `Semantics/` package (TaskFrame, WorldHistory, TaskModel, Truth evaluation)


### ["Counterfactual Worlds"](https://link.springer.com/article/10.1007/s10992-025-09793-8) (Brast-McKie 2025)

  - Hyperintensional semantics for counterfactual conditionals distinguishing necessarily equivalent antecedents
  - Foundation for the explanatory layer extension (counterfactual `□→` and causal `○→` operators)
  - Integrates with task semantics to evaluate counterfactual reasoning across possible world histories

### ["Identity and Aboutness"](https://link.springer.com/article/10.1007/s10992-021-09612-w) (Brast-McKie 2021)

  - State-based semantics using verifier/falsifier pairs to capture fine-grained propositional content
  - Enables distinctions between necessarily equivalent propositions based on what they are *about*
  - Theoretical foundation for constitutive explanatory reasoning (grounding `≤`, essence `⊑`, and propositional identity `≡` operators)

---

## Bimodal Theory

The project also includes **Bimodal**, a complete propositional intensional logic combining S5 modal and linear temporal operators. Developed in parallel with Logos, Bimodal provides an excellent starting point for understanding modal-temporal reasoning and demonstrates the boundaries of purely intensional semantics.

The contrast between Bimodal's purely intensional semantics and Logos's hyperintensional foundation demonstrates the advantages of hyperintensional semantics for supporting a wider range of operators including explanatory, epistemic, and normative operators that require distinguishing necessarily equivalent propositions.

For the full presentation of Bimodal and its comparison with Logos, see [A Bimodal Logic for Tense and Modality](docs/research/bimodal-logic.md).

For implementation details, see [Theories/Bimodal/README.md](Theories/Bimodal/README.md).

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

This project is licensed under GPL-3.0. See [LICENSE](LICENSE) for details.

---

## Contributing

Contributions welcome! See [Contributing Guide](docs/development/CONTRIBUTING.md) for guidelines.

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

### Directory Convention

- **PascalCase**: Lean source directories (`Logos/`, `Theories/`, `Tests/`)
- **lowercase**: Non-code directories (`docs/`, `scripts/`, `benchmarks/`, `latex/`)

See [Directory Naming Convention](docs/development/CONTRIBUTING.md#3-directory-naming-convention) for details.

---

## Related Projects

- **[ModelChecker](https://github.com/benbrastmckie/ModelChecker)** - Parallel implementation of Logos semantic theory in Python/Z3 for countermodel generation and semantic verification. Together with ProofChecker, forms the dual verification architecture for RL training.

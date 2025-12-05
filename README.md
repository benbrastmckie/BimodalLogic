# Logos: A Formal Language of Thought

**Logos** is a formal language of thought designed for training AI systems in verified reasoning. It combines a **proof system** implemented in LEAN 4 with a **recursive semantic theory** implemented in the [Model-Checker](https://github.com/benbrastmckie/ModelChecker), creating a dual verification architecture that generates comprehensive training signals without human annotation.

## Motivations

Training AI systems to reason reliably requires both positive signals (valid inferences) and corrective signals (invalid inferences with counterexamples where the premises are true and the conclusion is false):

<!-- NOTE: the sentence above and the table below say the same thing. Better to make the sentence above both introduce the section and set up the table below to deliver the primary contrast. -->

| Component | Role | Training Signal |
|-----------|------|-----------------|
| **LEAN 4 Proof System** | Derives valid theorems with machine-checkable proofs | Positive RL signal |
| **Model-Checker** | Identifies invalid inferences with explicit countermodels | Corrective RL signal |

<!-- NOTE: Now explain the significance of having both types of signals since, in principle, every case case is either derivable or invalid if the logic is complete (it is strong enough to derive all valid principles), and if the logic is incomplete, the additional axioms and rules that are not derivable can be consistently added to strengthen the logic. -->

This dual verification approach offers three key advantages:

1. **Unbounded**: Infinite theorems are derivable from the axiom system
2. **Clean**: Soundness guarantees only valid inferences are derivable
3. **Justified**: LEAN 4 proofs provide verifiable receipts; Z3 countermodels refute invalid claims

<!-- NOTE: By defining a proof system that is sound over a semantics, the space of theorems and countermodels provides an infinite training ground upon which to challenge AI systems to get better at both reasoning with the operators included in the Logos (given the accumulation of derivations and known countermodels) and even more importantly, finding correct derivations within a proof system and finding countermodels within a semantics. This training methodology may eventually be extended further to include the identification of patterns of reasoning in natural language with operators of interest that have not yet been implemented in order to being to predict their logics, setting constraints on the logical consequences that a successful semantics for those operators would have to predict. Just as the space of theorems for any proof system, or space of models for any semantics are both infinite, so too the space of logical operators worth theorizing is unbounded. These ways in which reasoning are all infinitely extensible provides a supply of resources with which to train AI systems that is limited only by compute, and is perfectly clean and consistent. This contrasts sharply with other realms of training data which are typically finite and of limited quality, especially for sophisticated forms of reasoning with complex interactions between many different logical operators, something most humans are in no position to supply. A natural comparison here is with arithmetic which, although simple sums can be computed without at least a pen and paper, even these are typically memorized or computed by simulating computation by pen and paper in one's mind. By contrast, implementing arithmetic computations by hand or with a computer vastly outstrips what humans are naturally capable of. Something similar holds for logical reasoning which also requires a proof system and semantics in place of an arithmetic to compute accurately at any level of complexity. -->

Reasoning in Logos can be interpreted using the semantic clauses for the language, offering scalable transparency and oversight for sophisticated AI reasoning.

<!-- NOTE: The point above needs to be expanded to emphasize that in addition to reasoning from premises to a conclusion, the semantics in particular provides a means by which to evaluate the truth values of complex sentences with operators of interest if a model can be produced. For instance, if an accurate model (consisting of states, tasks which are transitions between states, times, priority orderings, credence functions, etc.) can be produced that satisfies the definition of the semantic models for some fragment of the Logos that includes counterfactual and causal operators, then we can read off which claims are already true that can be articulated in that language, and more importantly which claims can be made true by extending the semantic model in one way or another, providing a methodology for abductive reasoning by which claims are hypothesized, used to draw inferences that are easy to test, and then either refuted or supported if the tests can be shown to be consistent with the hypothesis. Training AI systems to reason in the Logos which is interpreted by semantic models together with the semantic clauses for the operators provides a pathway not just systematic deductive reasoning, but abductive reasoning which draws the best explanation as an inference, and inductive reasoning which tests those explanations by collecting empirical feedback. -->

For theoretical background, see the [LogicNotes](https://github.com/benbrastmckie/LogicNotes) which aims to articulate the formal theory for the Logos in a human readable notation to complement its encoding in Lean and the Model-Checker.

## Layered Architecture

Logos has a **layered architecture** supporting progressive extensibility. All layers share a common semantic foundation: hyperintensional task semantics where possible worlds are functions from times to world-states, constrained by task relations.

<!-- NOTE: Don't use any formal symbols in the table below for compactness and consistency. Also include the extensional operators in 'Core'. And Explanatory  -->

| Layer | Operators | Purpose |
|-------|-----------|---------|
| **Core** (implemented) | Extensional, modal, temporal | Foundation for all reasoning |
| **Explanatory** (planned) | Counterfactual, causal, constitutive | Reasoning about what would happen and why|
| **Epistemic** (planned) | Belief, probability, indicative | Reasoning under uncertainty |
| **Normative** (planned) | Deontic, agential, preferential | Ethical and cooperative reasoning |

The language is open to further extensions beyond these four layers.

<!-- NOTE: Make the below brief like 'See also: link | link | ...' -->

**For philosophical foundations**: See [METHODOLOGY.md](Documentation/UserGuide/METHODOLOGY.md)
**For extension specifications**: See [LAYER_EXTENSIONS.md](Documentation/Research/LAYER_EXTENSIONS.md)

## Current Implementation

<!-- NOTE: these subsections below need to be expanded to explain what these operators are useful (what contingent examples they can be used to express and evaluate) and what theorems can be shown to be valid, providing general laws of thought for reasoning about any subject-matter -->

Logos currently implements the Core Layer of Logos - the bimodal logic TM providing the foundation for all planned extensions.

#### Operators

<!-- NOTE: use the glossary conventions 'H', 'G', 'F', 'P' -->

- **Modal**: `□` (necessity), `◇` (possibility) - S5 modal logic
- **Temporal**: `Past` (universal past), `Future` (universal future), `past` (sometime past), `future` (sometime future), `always`/`△` (at all times), `sometimes`/`▽` (at a time)

#### Axioms

<!-- NOTE: use the glossary conventions 'H', 'G', 'F', 'P' -->

- **S5 Modal**: MT (`□φ → φ`), M4 (`□φ → □□φ`), MB (`φ → □◇φ`)
- **Temporal**: T4 (`Future φ → Future Future φ`), TA (`φ → Future past φ`), TL (`△ φ → Future Past φ`)
- **Bimodal Interaction**: MF (`□φ → □Future φ`), TF (`□φ → Future □φ`)

<!-- NOTE: give an concrete example or two -->

#### Perpetuity Principles (Key Theorems)

<!-- NOTE: mention that in addition to describing inferences with a single operator like the introduction or elimination rules for conjunction, or the inferences with some collection of operators of a single type of operators like the extensional operators, there is also a question of how two types of operators interact like the modal and extensional operators, or the modal, extensional, and tense operators as below  -->

- **P1**: `□φ → △φ` (what is necessary is always the case)
- **P2**: `▽φ → ◇φ` (what is sometimes the case is possible)
- **P3**: `□φ → □△φ` (necessity of perpetuity)
- **P4**: `◇▽φ → ◇φ` (possibility of occurrence)
- **P5**: `◇▽φ → △◇φ` (persistent possibility)
- **P6**: `▽□φ → □△φ` (occurrent necessity is perpetual)

<!-- NOTE: give an concrete example or two -->

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
Logos's layered architecture enables incremental extension from core TM logic to explanatory, epistemic, and normative reasoning. Each extension provides independent value while building toward comprehensive AI reasoning capabilities (see [Progressive Extension Methodology](#progressive-extension-methodology) for details).

### 5. Theoretical Innovation
- **Task Semantics**: Compositional account of possible worlds from [Possible Worlds paper](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf)
- **Perpetuity Principles**: Novel theorems connecting modal and temporal operators
- **Hyperintensional Foundation**: Supports explanatory reasoning extensions from [recent research](https://link.springer.com/article/10.1007/s10992-025-09793-8)
- **LEAN 4 Implementation**: First complete formalization of TM bimodal logic

## Quick Status

**MVP Status**: Core Logos (TM) Complete - Foundation for Planned Extensions

- **Soundness**: Complete (8/8 axioms, 7/7 rules proven, zero sorry)
- **Semantics**: Complete (zero sorry in all semantics files)
- **Perpetuity**: All 6 principles available (P1-P6)
- **Tactics**: 4/12 implemented with 50 tests
- **Completeness**: Infrastructure only (proofs not started)

**For detailed status**: See [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | **For limitations**: See [KNOWN_LIMITATIONS.md](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) | **For task tracking**: See [TODO.md](TODO.md)

## Dual Verification Architecture

Logos and Model-Checker form a **complementary dual verification architecture** providing comprehensive training signals for AI systems learning to reason in Logos.

### Logos: Syntactic Verification

**Role**: LEAN 4 proof assistant for Logos
- Derives valid theorems from TM axioms via formal proof
- Provides proof receipts with mathematical certainty
- Generates positive RL training signals (valid inferences)
- Implements task semantics for soundness/completeness theorems

**Current Status**: MVP complete with partial metalogic (5/8 axioms, 4/7 rules proven)

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

**For integration details**: See [INTEGRATION.md](Documentation/UserGuide/INTEGRATION.md)

## Application Domains

The Logos architecture enables domain-specific operator combinations, demonstrating how planned extensions can be composed for specific use cases:

### Domain-Specific Operator Combinations

**Medical Planning** (Core + Explanatory + Epistemic):
- Core operators: Modal (`□`, `◇`) + Temporal (`Future`, `Past`) for treatment timelines
- Explanatory operators: Counterfactual (`□→`, `◇→`) for evaluating treatment strategies
- Epistemic operators: Probability (`Pr`), belief (`B`) for uncertainty quantification in diagnosis and prognosis
- Example: `Prescribe(DrugA) ∧ Taking(MedicationX) □→ F(Normalize(BloodPressure)) ∧ F(Occur(LiverDamage))`
  - Evaluates what would happen under Drug A prescription given current medication
  - Distinguishes necessary consequences (`□→`) from possible consequences (`◇→`)

**Legal Reasoning** (Core + Epistemic + Normative):
- Core operators: Modal + Temporal for tracking events and beliefs across time
- Epistemic operators: Belief (`B`), epistemic modals (`Mi`, `Mu`) for evidence analysis
- Normative operators: Obligation (`O`), Permission (`P`) for legal requirements and permissions
- Example: Tracking how evidence reveals agent beliefs and motives, constructing narratives connecting motive to action

**Multi-Agent Coordination** (Core + All Extensions):
- Core: Modal + Temporal for action timelines and coordination constraints
- Explanatory: Counterfactuals for evaluating alternative strategies
- Epistemic: Belief operators for modeling other agents' knowledge states
- Normative: Deontic operators (`O`, `P`) for obligations and permissions in negotiation

---

**For philosophical foundations and progressive methodology**: See [METHODOLOGY.md](Documentation/UserGuide/METHODOLOGY.md) | **For Layer 1-3 specifications**: See [LAYER_EXTENSIONS.md](Documentation/Research/LAYER_EXTENSIONS.md) | **For technical specification**: See [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md)

## Theoretical Foundations

Logos implements formal semantics developed in recent research:

**Task Semantics for Possible Worlds**:
- **Paper**: ["The Construction of Possible Worlds"](https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf) (Brast-McKie, 2025)
  - Compositional semantics drawing on non-deterministic dynamical systems theories
  - Complete implementation in `Semantics/` package (TaskFrame, WorldHistory, TaskModel, Truth evaluation)

**Hyperintensional Semantics Foundation**:
- **Papers**: ["Identity and Aboutness"](https://link.springer.com/article/10.1007/s10992-021-09612-w) (2021), ["Counterfactual Worlds"](https://link.springer.com/article/10.1007/s10992-025-09793-8) (2025)
  - State-based semantics enabling fine-grained distinctions for constitutive explanatory reasoning
  - Foundation for planned extensions (counterfactual, causal, constitutive operators)

## Installation

### Requirements

- LEAN 4 v4.14.0 or later
- Lake (included with LEAN 4)
- VS Code with lean4 extension (recommended)

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/Logos.git
cd Logos

# Build the project
lake build

# Run tests
lake test
```

## Documentation

### Getting Started (New Users)

- [Tutorial](Documentation/UserGuide/TUTORIAL.md) - Getting started with Logos
- [Examples](Documentation/UserGuide/EXAMPLES.md) - Modal, temporal, and bimodal examples
- [Logical Operators Glossary](Documentation/Reference/OPERATORS.md) - Formal symbols reference

### Architecture & Design

- [Logos Methodology](Documentation/UserGuide/METHODOLOGY.md) - Philosophical foundations and layer architecture
- [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md) - System design and TM logic specification
- [Integration Guide](Documentation/UserGuide/INTEGRATION.md) - Model-Checker integration

### Development (Contributing)

- [Contributing](Documentation/ProjectInfo/CONTRIBUTING.md) - How to contribute
- [LEAN Style Guide](Documentation/Development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Testing Standards](Documentation/Development/TESTING_STANDARDS.md) - Test requirements
- [Tactic Development](Documentation/Development/TACTIC_DEVELOPMENT.md) - Custom tactics

### Project Status (Keep Updated)

- [TODO.md](TODO.md) - **Task tracking and progress** (central task management)
- [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module status tracking
- [Known Limitations](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) - Gaps and workarounds
- [Versioning Policy](Documentation/ProjectInfo/VERSIONING.md) - Semantic versioning policy

### Research & Extensions

- [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md) - Layers 1-3 specifications
- [Dual Verification](Documentation/Research/DUAL_VERIFICATION.md) - RL training architecture
- [Proof Library Design](Documentation/Research/PROOF_LIBRARY_DESIGN.md) - Theorem caching architecture

### Advanced Topics

- [Metaprogramming Guide](Documentation/Development/METAPROGRAMMING_GUIDE.md) - LEAN 4 metaprogramming and tactic development
- [Quality Metrics](Documentation/Development/QUALITY_METRICS.md) - Quality targets and standards
- [Module Organization](Documentation/Development/MODULE_ORGANIZATION.md) - Project structure
- [Phased Implementation](Documentation/Development/PHASED_IMPLEMENTATION.md) - Wave-based implementation roadmap
- [Directory README Standard](Documentation/Development/DIRECTORY_README_STANDARD.md) - Directory-level documentation requirements
- [Documentation Quality Checklist](Documentation/Development/DOC_QUALITY_CHECKLIST.md) - Quality assurance checklist

### API Reference

- [Generated API Documentation](.lake/build/doc/) - Run `lake build :docs` to generate

## Project Structure

```
Logos/
├── Logos.lean           # Library root (re-exports all public modules)
├── Logos/               # Main source directory (see Logos/README.md)
│   ├── Syntax/                 # Formula types, parsing, DSL
│   │   ├── Formula.lean        # Core formula inductive type
│   │   └── Context.lean        # Proof context (premise lists)
│   ├── ProofSystem/            # Axioms and inference rules
│   │   ├── Axioms.lean         # TM axiom schemata
│   │   └── Derivation.lean     # Derivability relation and inference rules
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
│       ├── Tactics.lean        # Custom tactics
│       └── ProofSearch.lean    # Automated proof search
├── LogosTest/           # Test suite (see LogosTest/README.md)
│   ├── LogosTest.lean   # Test library root
│   ├── Syntax/                 # Tests for formula construction
│   ├── ProofSystem/            # Tests for axioms and rules
│   ├── Semantics/              # Tests for semantics
│   ├── Integration/            # Cross-module tests
│   └── Metalogic/              # Soundness/completeness tests
├── Archive/                    # Pedagogical examples (see Archive/README.md)
│   ├── Archive.lean            # Archive library root
│   └── BimodalProofs.lean      # Combined modal-temporal examples
├── Documentation/              # User documentation (see Documentation/README.md)
│   ├── UserGuide/              # User-facing documentation
│   │   ├── ARCHITECTURE.md         # System design and TM logic specification
│   │   ├── METHODOLOGY.md          # Philosophical foundations and layer architecture
│   │   ├── TUTORIAL.md             # Getting started guide
│   │   ├── EXAMPLES.md             # Usage examples
│   │   └── INTEGRATION.md          # Model-Checker integration
│   ├── ProjectInfo/            # Project status and contribution info
│   │   ├── IMPLEMENTATION_STATUS.md  # Module-by-module status tracking
│   │   ├── KNOWN_LIMITATIONS.md      # Gaps, explanations, workarounds
│   │   ├── CONTRIBUTING.md           # Contribution guidelines
│   │   └── VERSIONING.md             # Semantic versioning policy
│   ├── Development/            # Developer standards
│   │   ├── DIRECTORY_README_STANDARD.md # Directory-level documentation requirements
│   │   ├── DOC_QUALITY_CHECKLIST.md     # Quality assurance checklist
│   │   ├── LEAN_STYLE_GUIDE.md          # Coding conventions
│   │   ├── METAPROGRAMMING_GUIDE.md     # LEAN 4 metaprogramming and tactics
│   │   ├── MODULE_ORGANIZATION.md       # Directory structure
│   │   ├── PHASED_IMPLEMENTATION.md     # Wave-based implementation roadmap
│   │   ├── QUALITY_METRICS.md           # Quality targets
│   │   ├── TACTIC_DEVELOPMENT.md        # Custom tactic patterns
│   │   └── TESTING_STANDARDS.md         # Test requirements
│   ├── Research/               # Research documentation
│   │   ├── DUAL_VERIFICATION.md      # RL training architecture
│   │   ├── LAYER_EXTENSIONS.md       # Layers 1-3 specifications
│   │   └── PROOF_LIBRARY_DESIGN.md   # Theorem caching architecture
│   └── Reference/              # Reference materials
│       ├── OPERATORS.md              # Formal symbols reference
│       └── GLOSSARY.md               # Key concepts and definitions
├── lakefile.toml               # LEAN 4 build configuration
├── lean-toolchain              # LEAN version pinning
├── .gitignore                  # Git exclusions
└── .github/workflows/ci.yml    # CI/CD pipeline
```

## Related Projects

- **[Model-Checker](https://github.com/benbrastmckie/ModelChecker)** - Z3-based semantic verification implementing hyperintensional semantics (v1.2.12) - complementary tool for dual verification architecture
- **[LogicNotes](https://github.com/benbrastmckie/LogicNotes)** - Theoretical foundations and compressed overview of TM logic subsystems
- **FormalizedFormalLogic/Foundation** - LEAN 4 modal logic library (patterns adopted)
- **Mathlib4** - LEAN 4 mathematics library (style conventions followed)

## License

MIT License - see [LICENSE](LICENSE) for details.

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

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](Documentation/ProjectInfo/CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Install LEAN 4 (elan recommended)
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh

# Clone and build
git clone https://github.com/yourusername/Logos.git
cd Logos
lake build

# Run tests before submitting PR
lake test
lake lint
```

# Logos Archive

Pedagogical examples demonstrating the Logos library and bimodal logic TM (Tense and Modality), designed for learning and reference.

**Active path notice:** The canonical import path for these examples is now `Logos/Examples/` (e.g., `import Logos.Examples`). The legacy `Archive/` modules remain as thin shims for backward compatibility; add new examples under `Logos/Examples/` going forward.

## Purpose

These examples illustrate:
- Key concepts in bimodal logic TM (modal necessity/possibility + temporal past/future)
- Idiomatic proof patterns for TM theorems
- Practical usage of the Logos library
- Perpetuity principles connecting modal and temporal operators
- Proof construction strategies for modal, temporal, and bimodal reasoning

## Example Categories

### Modal Logic Examples (Implemented)
- **ModalProofs.lean** (295 lines): S5 modal logic theorem proofs
  - Axiom K (modal distribution): `□(φ → ψ) → (□φ → □ψ)`
  - Axiom T (reflexivity): `□φ → φ`
  - Axiom 4 (transitivity): `□φ → □□φ`
  - Axiom B (symmetry): `φ → □◇φ`
  - Diamond operator examples: `◇φ = ¬□¬φ`
- **ModalProofStrategies.lean** (511 lines): Pedagogical examples for S5 modal proof construction
  - 20 examples demonstrating modal proof strategies
  - 65.6% comment density (335/511 lines)
  - Necessity chains (iterating M4)
  - Possibility proofs (working with `◇φ = ¬□¬φ`)
  - Modal modus ponens patterns
  - S5 characteristic theorems

### Temporal Logic Examples (Implemented)
- **TemporalProofs.lean** (413 lines): Linear temporal logic theorem proofs
  - Past and future operators (`H`, `P`, `G`, `F`)
  - Temporal duality principles: `swap_temporal`
  - Temporal axioms: TA (connectedness), TL (linearity)
  - Always/eventually operators: `△φ`, `▽φ`
- **TemporalProofStrategies.lean** (647 lines): Pedagogical examples for temporal proof construction
  - 26 examples demonstrating temporal proof strategies
  - 70.6% comment density (457/647 lines)
  - Future iteration chains (T4 axiom)
  - Temporal duality transformations (past ↔ future)
  - Connectedness reasoning (TA axiom)
  - Always/eventually proofs

### Bimodal Examples (Implemented)
- **BimodalProofs.lean** (244 lines): Combined modal-temporal reasoning
  - Perpetuity principle P1: `□φ → △φ` (necessity implies always)
  - Perpetuity principle P2: `▽φ → ◇φ` (sometimes implies possible)
  - Perpetuity principle P3: `□φ → □△φ` (necessity of perpetuity)
  - Modal-temporal interactions and task semantics applications
- **BimodalProofStrategies.lean** (737 lines): Pedagogical examples for bimodal proof construction
  - 29 examples demonstrating bimodal proof strategies
  - 69.7% comment density (514/737 lines)
  - Perpetuity principle applications (P1-P6 usage patterns)
  - Modal-temporal axiom strategies (MF and TF)
  - Helper lemma construction (`imp_trans`, `combine_imp_conj`)
  - Complex multi-step proof assembly

### Temporal Structures Examples (Implemented)
- **TemporalStructures.lean** (211 lines): Polymorphic temporal type examples
  - Integer time frames (discrete temporal logic)
  - Rational time frames (dense temporal reasoning)
  - Real time frames (continuous time modeling)
  - Demonstrates polymorphic `TaskFrame T` and `WorldHistory F`

## Learning Path

For newcomers to TM logic and Logos, we recommend this progression:

### Beginner Path
1. **Start here**: Read [TUTORIAL.md](../Documentation/UserGuide/TUTORIAL.md) for basic concepts
2. **Then**: Study [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) for TM logic specification
3. **Practice Modal**: Explore `ModalProofs.lean` for S5 modal logic examples
4. **Learn Modal Strategies**: Study `ModalProofStrategies.lean` for proof construction techniques
5. **Practice Temporal**: Explore `TemporalProofs.lean` for linear temporal logic examples
6. **Learn Temporal Strategies**: Study `TemporalProofStrategies.lean` for temporal proof techniques

### Intermediate Path
7. **Bimodal Introduction**: Read `BimodalProofs.lean` for perpetuity principles (P1-P3)
8. **Bimodal Strategies**: Study `BimodalProofStrategies.lean` for modal-temporal interaction patterns
9. **Polymorphic Structures**: Explore `TemporalStructures.lean` for type-polymorphic temporal reasoning

### Advanced Path
10. **Source Code**: Read perpetuity principle proofs in `Logos/Core/Theorems/Perpetuity.lean`
11. **Soundness Proofs**: Study `Logos/Core/Metalogic/Soundness.lean` for semantic validity
12. **Automation**: Explore `Logos/Core/Automation/Tactics.lean` for proof automation

### Proof Strategy Focus

For learners specifically interested in proof construction techniques:
- **Modal Strategies**: `ModalProofStrategies.lean` - 20 examples (necessity chains, possibility proofs, S5 patterns)
- **Temporal Strategies**: `TemporalProofStrategies.lean` - 26 examples (future iteration, duality, connectedness)
- **Bimodal Strategies**: `BimodalProofStrategies.lean` - 29 examples (perpetuity principles, MF/TF axioms, helper lemmas)

## How to Run Examples

### In VS Code

1. Open example file in VS Code with lean4 extension installed
2. LEAN will type-check the file automatically
3. Hover over definitions to see types and documentation
4. Click on theorem names to jump to definitions
5. Use `Ctrl+Shift+Enter` to execute entire file

### In Command Line

```bash
# Type-check specific examples
lake env lean Archive/ModalProofStrategies.lean
lake env lean Archive/TemporalProofStrategies.lean
lake env lean Archive/BimodalProofStrategies.lean

# Build the entire Archive module
lake build Archive
```

### Importing Examples

```lean
-- Import specific example modules
import Archive.ModalProofs
import Archive.ModalProofStrategies
import Archive.TemporalProofs
import Archive.TemporalProofStrategies
import Archive.BimodalProofs
import Archive.BimodalProofStrategies
import Archive.TemporalStructures

-- Or import entire archive
import Archive
```

### Interactive Exploration

```lean
-- In a new .lean file, import Archive modules and explore
import Archive.ModalProofStrategies
import Archive.TemporalProofStrategies
import Archive.BimodalProofStrategies

-- Check example theorems
#check perpetuity_1_example  -- From BimodalProofs
#check perpetuity_2_example  -- From BimodalProofs

-- Try your own proofs
example (φ : Formula) : ⊢ (φ.box.imp φ) := by
  apply Derivable.axiom
  apply Axiom.modal_t
```

## Contributing Examples

New pedagogical examples should:

- **Have clear docstrings**: Explain the concept being demonstrated
- **Include step-by-step comments**: Guide learners through the proof
- **Follow style guide**: See [LEAN_STYLE_GUIDE.md](../Documentation/Development/LEAN_STYLE_GUIDE.md)
- **Be accessible**: Avoid overly complex proofs; prioritize clarity over brevity
- **Include context**: Explain why the theorem is interesting or important
- **Test thoroughly**: Ensure examples type-check with `lake build Archive`

### Example Contribution Workflow

1. Create example file in `Archive/` (e.g., `MyExamples.lean`)
2. Write comprehensive docstrings and proof comments
3. Add module to `Archive.lean` import list (currently commented out)
4. Test: `lake env lean Archive/MyExamples.lean`
5. Submit pull request with description of educational value

See [CONTRIBUTING.md](../Documentation/Development/CONTRIBUTING.md) for general contribution guidelines.

## Current Status

**Implemented** (All 8 modules complete):

### Core Proof Modules
- **ModalProofs.lean** (295 lines): S5 modal logic theorem proofs
- **TemporalProofs.lean** (413 lines): Linear temporal logic theorem proofs
- **BimodalProofs.lean** (244 lines): Perpetuity principles P1-P3
- **TemporalStructures.lean** (211 lines): Polymorphic temporal type examples

### Proof Strategy Modules
- **ModalProofStrategies.lean** (511 lines, 20 examples): S5 modal proof construction strategies
- **TemporalProofStrategies.lean** (647 lines, 26 examples): Temporal proof construction strategies
- **BimodalProofStrategies.lean** (737 lines, 29 examples): Bimodal proof construction strategies

### Total Archive Statistics
- **Total Lines**: ~3,058 lines of LEAN 4 code
- **Total Examples**: 75+ pedagogical examples
- **Average Comment Density**: 68.6% (exceeds 50% standard)
- **Build Status**: All modules compile successfully with `lake build Archive`

For detailed implementation status, see [IMPLEMENTATION_STATUS.md](../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md).

## Related Documentation

- [Tutorial](../Documentation/UserGuide/TUTORIAL.md) - Getting started with Logos
- [Examples](../Documentation/UserGuide/EXAMPLES.md) - Usage examples and patterns
- [Architecture](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
- [Perpetuity Module](../Logos/Theorems/Perpetuity.lean) - Perpetuity principle proofs (P1-P6)
- [Archive.lean](Archive.lean) - Archive module documentation

## Navigation

- **Up**: [Logos Root](../)
- **Documentation**: [Documentation/](../Documentation/)
- **Source Code**: [Logos/](../Logos/)
- **Tests**: [LogosTest/](../LogosTest/)

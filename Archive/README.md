# Logos Archive

Pedagogical examples demonstrating the Logos library and bimodal logic TM (Tense and Modality), designed for learning and reference.

## Purpose

These examples illustrate:
- Key concepts in bimodal logic TM (modal necessity/possibility + temporal past/future)
- Idiomatic proof patterns for TM theorems
- Practical usage of the Logos library
- Perpetuity principles connecting modal and temporal operators

## Example Categories

### Bimodal Examples (Implemented)
- **BimodalProofs.lean**: Combined modal-temporal reasoning
  - Perpetuity principle P1: `□φ → △φ` (necessity implies always)
  - Perpetuity principle P2: `▽φ → ◇φ` (sometimes implies possible)
  - Perpetuity principle P3: `□φ → □△φ` (necessity of perpetuity)
  - Modal-temporal interactions and task semantics applications

### Modal Logic Examples (Planned)
- **ModalProofs.lean**: S5 modal logic theorems (future implementation)
  - Axiom K (modal distribution)
  - Axiom T (reflexivity)
  - Axiom 4 (transitivity)
  - Axiom B (symmetry)

### Temporal Logic Examples (Planned)
- **TemporalProofs.lean**: Linear temporal logic theorems (future implementation)
  - Past and future operators
  - Temporal duality principles
  - Temporal axioms (TA, TL)

## Learning Path

For newcomers to TM logic and Logos, we recommend this progression:

1. **Start here**: Read [TUTORIAL.md](../Documentation/UserGuide/TUTORIAL.md) for basic concepts
2. **Then**: Study [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) for TM logic specification
3. **Practice**: Explore `BimodalProofs.lean` for perpetuity principles
4. **Advanced**: Read perpetuity principle proofs in `Logos/Theorems/Perpetuity.lean`

## How to Run Examples

### In VS Code

1. Open example file in VS Code with lean4 extension installed
2. LEAN will type-check the file automatically
3. Hover over definitions to see types and documentation
4. Click on theorem names to jump to definitions
5. Use `Ctrl+Shift+Enter` to execute entire file

### In Command Line

```bash
# Type-check an example
lake env lean Archive/BimodalProofs.lean

# Build the entire Archive module
lake build Archive
```

### Importing Examples

```lean
-- Import specific example module
import Archive.BimodalProofs

-- Import entire archive (when more examples are added)
import Archive
```

### Interactive Exploration

```lean
-- In a new .lean file, import Archive and explore
import Archive.BimodalProofs

#check perpetuity_1_example
#check perpetuity_2_example

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

See [CONTRIBUTING.md](../Documentation/ProjectInfo/CONTRIBUTING.md) for general contribution guidelines.

## Current Status

**Implemented**:
- BimodalProofs.lean: Perpetuity principles P1-P3 with pedagogical examples

**Planned**:
- ModalProofs.lean: S5 modal logic examples (imports commented in Archive.lean)
- TemporalProofs.lean: Linear temporal logic examples (imports commented in Archive.lean)

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

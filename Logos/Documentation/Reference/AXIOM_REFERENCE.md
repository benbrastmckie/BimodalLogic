# Logos Axiom Reference

Axiom reference for Logos logic.

## Current Implementation

Logos currently **re-exports Bimodal axioms**. For the complete axiom reference, see:

**→ [Bimodal Axiom Reference](../../../Bimodal/Documentation/Reference/AXIOM_REFERENCE.md)**

## Axiom Summary

The TM (Tense and Modality) axioms re-exported from Bimodal:

### Propositional Axioms

| Axiom | Name | Schema |
|-------|------|--------|
| P1 | Self-implication | `φ → φ` |
| P2 | Weakening | `φ → (ψ → φ)` |
| P3 | Distribution | `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` |

### Modal Axioms

| Axiom | Name | Schema |
|-------|------|--------|
| MT | Reflexivity | `□φ → φ` |
| M4 | Transitivity | `□φ → □□φ` |
| MB | Symmetry | `φ → □◇φ` |
| MK | Distribution | `□(φ → ψ) → (□φ → □ψ)` |

### Temporal Axioms

| Axiom | Name | Schema |
|-------|------|--------|
| T4 | Temporal transitivity | `△φ → △△φ` |
| TA | Temporal density | `△φ → φ` |
| TL | Temporal linearity | `▽▽φ → (▽φ ∨ φ ∨ △φ)` |
| TK | Temporal distribution | `△(φ → ψ) → (△φ → △ψ)` |

### Interaction Axioms

| Axiom | Name | Schema |
|-------|------|--------|
| MF | Modal-future | `□φ → △φ` |
| TF | Temporal-future | `△□φ → □△φ` |
| TD | Temporal-duality | `¬△φ ↔ ▽¬φ` |

## Future Extensions

When Logos is fully implemented, it will add axioms for:

- **Epistemic logic**: Knowledge (`K`) and belief (`B`) axioms
- **Deontic logic**: Obligation (`O`) and permission (`P`) axioms
- **Grounding**: Explanatory relation axioms

For details on planned extensions, see [EXTENSION_STUBS.md](EXTENSION_STUBS.md).

## See Also

- [Bimodal Axiom Reference](../../../Bimodal/Documentation/Reference/AXIOM_REFERENCE.md)
- [Extension Stubs](EXTENSION_STUBS.md) - Planned extension modules
- [Theory Comparison](../../../Documentation/Research/THEORY_COMPARISON.md)

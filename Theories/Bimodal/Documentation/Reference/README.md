# Bimodal Reference

Reference materials for the Bimodal TM logic library.

## Contents

| Document | Description |
|----------|-------------|
| [AXIOM_REFERENCE.md](AXIOM_REFERENCE.md) | Complete axiom schemas with examples |
| [TACTIC_REFERENCE.md](TACTIC_REFERENCE.md) | Bimodal-specific tactic usage |

## Quick Lookup

### Axioms by Category

**Modal Axioms**:
- MT (Modal T): `□φ → φ`
- M4 (Modal 4): `□φ → □□φ`
- MB (Modal B): `φ → □◇φ`
- MK (Modal K): `□(φ → ψ) → (□φ → □ψ)`

**Temporal Axioms**:
- T4 (Future 4): `△φ → △△φ`
- TA (Temporal A): `△φ → ▽△φ`
- TL (Left): `▽△φ → φ`
- TK (Temporal K): `△(φ → ψ) → (△φ → △ψ)`

**Interaction Axioms**:
- MF: `□△φ ↔ △□φ`
- TF: `□▽φ ↔ ▽□φ`

See [AXIOM_REFERENCE.md](AXIOM_REFERENCE.md) for complete details.

### Common Tactics

| Tactic | Purpose |
|--------|---------|
| `modal_t` | Apply modal T axiom |
| `apply_axiom` | Apply specific axiom schema |
| `modal_search` | Automated modal proof search |
| `temporal_search` | Automated temporal proof search |

See [TACTIC_REFERENCE.md](TACTIC_REFERENCE.md) for usage details.

## See Also

- [Project Operators Reference](../../../docs/Reference/OPERATORS.md) - Symbol notation
- [Project API Reference](../../../docs/Reference/API_REFERENCE.md) - Full API docs

## Navigation

- **Up**: [Bimodal Documentation](../)
- **User Guide**: [UserGuide/](../UserGuide/)
- **Project Info**: [ProjectInfo/](../ProjectInfo/)

# Bimodal Reference

Reference materials for the Bimodal TM logic library.

## Contents

| Document | Description |
|----------|-------------|
| [axiom-reference.md](axiom-reference.md) | Complete axiom schemas with examples |
| [tactic-reference.md](tactic-reference.md) | Bimodal-specific tactic usage |

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

See [axiom-reference.md](axiom-reference.md) for complete details.

### Common Tactics

| Tactic | Purpose |
|--------|---------|
| `modal_t` | Apply modal T axiom |
| `apply_axiom` | Apply specific axiom schema |
| `modal_search` | Automated modal proof search |
| `temporal_search` | Automated temporal proof search |

See [tactic-reference.md](tactic-reference.md) for usage details.

## See Also

- [Project Operators Reference](../../../docs/reference/operators.md) - Symbol notation
- [Project API Reference](../../../docs/reference/API_REFERENCE.md) - Full API docs

## Navigation

- **Up**: [Bimodal Documentation](../)
- **User Guide**: [UserGuide/](../user-guide/)
- **Project Info**: [ProjectInfo/](../project-info/)

# Reference Documentation

[Back to Documentation](../README.md)

Quick reference materials for working with ProofChecker.

**Audience**: All users looking up APIs, symbols, and terminology

## Theory-Specific References

Most reference materials are theory-specific. See:

| Theory | Key References |
|--------|----------------|
| **Bimodal** | [Axioms](axiom-reference.md), [Operators](operators.md), [Tactics](tactic-reference.md) |

## Project-Wide Reference

| Document | Description |
|----------|-------------|
| [API_REFERENCE.md](API_REFERENCE.md) | Project-wide API documentation (key types, functions, and modules) |

## Quick Lookup

### Looking for a Symbol?

See theory-specific operator references:
- **Bimodal**: [Operators](operators.md) - Modal, temporal, propositional operators

### Looking for API Details?

See [API_REFERENCE.md](API_REFERENCE.md) for the project-wide API:
- Core types (Formula, Model, Frame)
- Key functions and their signatures
- Module organization

## Related Documentation

- [User Guides](../user-guide/) - Integration guides
- [Development Standards](../development/) - Coding conventions
- [Implementation Status](../project-info/implementation-status.md) - Current capabilities

---

[Back to Documentation](../README.md)

---

## Merged from the Lean source tree

The `docs/` tree was folded into this one. Previously the repository
carried two parallel `docs/` trees, and this file cross-linked into the other via
`docs/...` — an incoherence that the merge removes. The index below
came from the source-tree copy of this file; its entries now refer to files in this
directory.

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

- [Project Operators Reference](operators.md) - Symbol notation
- [Project API Reference](API_REFERENCE.md) - Full API docs

## Navigation

- **Up**: [Bimodal Documentation](../)
- **User Guide**: [UserGuide/](../user-guide/)
- **Project Info**: [ProjectInfo/](../project-info/)

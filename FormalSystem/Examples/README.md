# Examples

Sorry-free example proofs for TM bimodal logic.

## Contents

| File | Description |
|------|-------------|
| [Walkthrough.lean](Walkthrough.lean) | End-to-end walkthrough of the metatheory, for readers new to the repository (sorry-free) |
| [BimodalProofs.lean](BimodalProofs.lean) | Combined modal-temporal proof examples (sorry-free) |
| [TemporalStructures.lean](TemporalStructures.lean) | Concrete temporal structure examples (sorry-free) |

## Purpose

These files demonstrate:
- How to construct derivation trees for modal-temporal theorems
- Concrete instantiations of the frame hierarchy (dense and discrete orders)
- How the metatheory composes end to end: soundness, completeness, the tableau decision
  procedure, and frame-class sensitivity established by an explicit countermodel

Start with `Walkthrough.lean`. It is the one page a reader who knows modal logic but not this
repository can follow top to bottom; every declaration in it is named so that its axiom set can
be audited, and the audits are asserted in `Tests/BimodalTest/WalkthroughAxioms.lean`.

## Related Documentation

- [Parent README](../README.md)
- [Metalogic Results](../Metalogic/README.md) - Soundness, completeness, decidability

---

*Last verified: 2026-09-20*

# Canonical

Canonical model infrastructure for TM bimodal logic.

## Reflexive G/H Semantics (Task 29, Task 44)

Under reflexive semantics, G and H quantify over `s >= t` and `s <= t` respectively
(including the current time). The canonical accessibility relation is REFLEXIVE:

- `canonicalR_reflexive` is PROVEN via T-axiom
- No irreflexivity axiom (removed in Task 44 as inconsistent with reflexivity)

### Axiom-Free Reflexive Semantics

- ConstructiveFragment.lean provides reflexive preorder over MCSs
- Per-construction strictness pattern for local irreflexivity proofs
- All completeness proofs are axiom-free

## Contents

| File | Description |
|------|-------------|
| CanonicalTimeline.lean | Canonical timeline construction from MCSs |
| ConstructiveFragment.lean | Constructive fragment with reflexive preorder |

## Key Concepts

- **Canonical Timeline**: Timeline derived from MCS temporal accessibility
- **Reflexive Preorder**: Under reflexive G/H, CanonicalR is reflexive + transitive
- **Per-Construction Strictness**: Local strictness proofs via formula witnesses
- **Pure Syntax**: D constructed from temporal structure of MCSs

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Domain README](../Domain/README.md) - Domain construction from canonical timeline

---

*Last Updated: 2026-03-23 (Task 44 - axiom removal)*

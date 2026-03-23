# Canonical

Canonical model infrastructure for TM bimodal logic.

## Reflexive G/H Semantics (Task 29)

Under reflexive semantics, G and H quantify over `s >= t` and `s <= t` respectively
(including the current time). The canonical accessibility relation is REFLEXIVE:

- `canonicalR_reflexive` is PROVEN via T-axiom
- `canonicalR_irreflexive` is an AXIOM for order-theoretic enhancements only

### Two-Layer Architecture

**Layer 1 (Basic Completeness)**: Uses reflexive preorder structure.
- ConstructiveFragment.lean provides reflexive preorder over MCSs
- Does NOT require irreflexivity axiom

**Layer 2 (Order-Theoretic)**: Uses irreflexivity axiom.
- CanonicalIrreflexivityAxiom.lean provides `canonicalR_strict`
- Used by CantorApplication, DovetailedTimelineQuot for NoMaxOrder etc.

## Contents

| File | Description |
|------|-------------|
| CanonicalTimeline.lean | Canonical timeline construction from MCSs |
| CanonicalIrreflexivityAxiom.lean | Irreflexivity theorems for order-theoretic enhancements |
| ConstructiveFragment.lean | Constructive fragment with reflexive preorder |

## Key Concepts

- **Canonical Timeline**: Timeline derived from MCS temporal accessibility
- **Reflexive Preorder**: Under reflexive G/H, CanonicalR is reflexive + transitive
- **Order-Theoretic Enhancements**: NoMaxOrder, DenselyOrdered via irreflexivity axiom
- **Pure Syntax**: D constructed from temporal structure of MCSs

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Domain README](../Domain/README.md) - Domain construction from canonical timeline

---

*Last Updated: 2026-03-22 (Task 29 v8)*

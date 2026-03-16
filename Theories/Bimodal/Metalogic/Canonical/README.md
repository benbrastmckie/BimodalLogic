# Canonical

Canonical model infrastructure for TM bimodal logic.

## Contents

| File | Description |
|------|-------------|
| CanonicalTimeline.lean | Canonical timeline construction from MCSs |
| CanonicalIrreflexivityAxiom.lean | Axiom for canonical relation irreflexivity |
| ConstructiveFragment.lean | Constructive fragment of canonical model theory |

## Purpose

This module provides the canonical model construction that derives the
duration domain D from the syntax of TM logic. The key insight is that D
emerges from the temporal structure of maximal consistent sets.

## Key Concepts

- **Canonical Timeline**: Timeline derived from MCS temporal accessibility
- **Irreflexivity**: The canonical relation is irreflexive (no world accesses itself)
- **Pure Syntax**: D is constructed without importing external number types

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Domain README](../Domain/README.md) - Domain construction from canonical timeline

---

*Last Updated: 2026-03-16*

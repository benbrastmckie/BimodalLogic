# Domain

Duration domain construction for TM bimodal logic.

## Contents

| File | Description |
|------|-------------|
| CanonicalDomain.lean | Main domain construction from canonical timeline |
| DiscreteTimeline.lean | Discrete timeline quotient construction |
| DurationTransfer.lean | Transfer results between domain representations |

## Purpose

This module constructs the duration domain D from the canonical timeline,
satisfying the pure-syntax constraint that D must emerge from temporal
axioms rather than being imported as Int or Rat.

## Key Results

- **Dense Case**: D characterized via rational order properties
- **Discrete Case**: D characterized via integer order properties
- **Pure Syntax**: No external number types imported

## Sorry Status

The discrete timeline construction (`DiscreteTimeline.lean`) contains 7 sorries
in the SuccOrder and PredOrder instances. These are infrastructure lemmas that
do not affect the main completeness theorems.

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Canonical README](../Canonical/README.md) - Canonical timeline source

---

*Last Updated: 2026-03-16*

# ConservativeExtension

Conservative extension infrastructure for TM bimodal logic.

## Contents

| File | Description |
|------|-------------|
| ExtFormula.lean | Extended formula type with additional atoms |
| ExtDerivation.lean | Derivations in extended logic |
| Substitution.lean | Formula substitution infrastructure |
| Lifting.lean | Lifting theorems between base and extended logic |

## Purpose

This module provides infrastructure for proving that extensions of TM bimodal
logic are conservative - i.e., any theorem provable in the extension that uses
only base-logic formulas is also provable in the base logic.

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture

---

*Last Updated: 2026-03-16*

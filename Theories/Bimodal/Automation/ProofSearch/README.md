# ProofSearch

Bounded proof search infrastructure for TM bimodal logic.

This subdirectory contains the core search engine and search strategies used by the
Automation layer to find derivations up to a given depth bound.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Core.lean` | 1018 | Proof search core engine: depth-limited derivation search, term enumeration |
| `Strategies.lean` | 379 | Search strategies: heuristic ordering, pruning rules, backtracking policies |

## Key Definitions

- Core search functions for bounded derivation discovery
- Strategy combinators for guiding proof search
- Integration point for `tm_auto` and other high-level tactics

## Dependencies

- **Imports from**: `Bimodal.ProofSystem`, `Bimodal.Automation.AesopRules`
- **Used by**: `Bimodal.Automation.Tactics` (provides `tm_auto` infrastructure)

## Related Documentation

- [Automation README](../README.md)
- [Tactics subdirectory](../Tactics/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

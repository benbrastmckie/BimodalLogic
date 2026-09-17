# ProofSearch

Bounded proof search infrastructure for TM bimodal logic.

This subdirectory contains the core search engine and search strategies used by the
Automation layer to find derivations up to a given depth bound.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Core.lean` | 1,283 | Proof search core engine: depth-limited derivation search, term enumeration |
| `Strategies.lean` | 401 | Search strategies: heuristic ordering, pruning rules, backtracking policies |

## Key Definitions

- Core search functions for bounded derivation discovery
- Strategy combinators for guiding proof search
- Reached from `decide`'s fast path, not from any tactic (see below)

## Dependencies

- **Imports from**: `FormalSystem.ProofSystem`, `FormalSystem.Syntax`
- **Used by**: `FormalSystem.Metalogic.Decidability` (`decide`'s fast path calls
  `boundedSearchWithProof` before falling back to the tableau). This is a *different* engine
  from the one `FormalSystem.Automation.Tactics`'s `modal_search` runs
  (`Tactics/Search.lean`'s `searchProof`); the two have no import relationship.

## Related Documentation

- [Automation README](../README.md)
- [Tactics subdirectory](../Tactics/README.md)

---

*Last verified: 2026-09-17*

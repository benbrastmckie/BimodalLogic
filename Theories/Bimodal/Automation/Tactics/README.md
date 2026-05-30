# Tactics

Custom Lean 4 tactic implementations for TM bimodal logic proof development.

This subdirectory contains the tactic elaboration code and helper utilities that
implement the `apply_axiom`, `modal_t`, `tm_auto`, and related tactics.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Commands.lean` | 431 | Tactic command elaborators: `apply_axiom`, `modal_t`, `tm_auto`, `assumption_search` |
| `Helpers.lean` | 921 | Tactic helper infrastructure: term construction, goal manipulation, MetaM utilities |

## Key Definitions

- `apply_axiom`: Macro-based tactic that applies a TM axiom by name
- `modal_t`: Elaboration rule for reflexivity (Modal T axiom application)
- `tm_auto`: Comprehensive automation via Aesop with TMLogic rule set
- `assumption_search`: Search for a matching formula in the current context

## Dependencies

- **Imports from**: `Bimodal.ProofSystem`, `Bimodal.Automation.AesopRules`
- **Used by**: `Bimodal.Automation` (re-exported), downstream proofs

## Related Documentation

- [Automation README](../README.md)
- [ProofSearch subdirectory](../ProofSearch/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.

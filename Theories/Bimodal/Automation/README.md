# Automation

Custom tactics and proof automation for TM bimodal logic.

## Submodules

- **Tactics.lean**: Custom tactics for modal and temporal reasoning
  - `apply_axiom`: Apply TM axiom by name
  - `modal_t`: Apply modal T axiom automatically
  - `tm_auto`: Comprehensive TM automation with Aesop
  - `assumption_search`: Search for formula in context

- **AesopRules.lean**: Aesop rule set for TM logic
  - TMLogic rule set declaration
  - Forward chaining for proven axioms (MT, M4, MB, T4, TA)
  - Apply rules for core inference (modus_ponens, modal_k, temporal_k)
  - Normalization rules for derived operators

- **ProofSearch.lean**: Bounded proof search infrastructure
  - Depth-limited search for derivations
  - Heuristic-guided proof search

- **SuccessPatterns.lean**: Successful proof patterns and examples

## Quick Reference

**Where to find specific functionality**:

- **Basic Tactics**: See `apply_axiom`, `modal_t` in [Tactics.lean](Tactics.lean)
- **Aesop Integration**: See `tm_auto` tactic and TMLogic rule set in [AesopRules.lean](AesopRules.lean)
- **Proof Search**: See bounded_search infrastructure in [ProofSearch.lean](ProofSearch.lean)

## Usage Examples

```lean
-- Apply axiom by name
example : ⊢ (Formula.box p).imp p := by
  apply_axiom  -- Finds and applies Axiom.modal_t

-- Modal T application (automatic)
example (p : Formula) : [p.box] ⊢ p := by
  modal_t
  assumption

-- Comprehensive automation with Aesop
example : ⊢ (□p → p) := by
  tm_auto  -- Uses Aesop with TMLogic rule set
```

## Implementation Status

- `apply_axiom`: Functional (macro-based)
- `modal_t`: Functional (elab_rules)
- `tm_auto`: Functional with Aesop integration
- `assumption_search`: Functional with TacticM
- Bounded proof search: Infrastructure available

## Building and Type-Checking

```bash
# Build automation module
lake build Bimodal.Automation

# Type-check specific file
lake env lean Bimodal/Automation/Tactics.lean
lake env lean Bimodal/Automation/AesopRules.lean
lake env lean Bimodal/Automation/ProofSearch.lean
```

## API Documentation

For detailed API documentation, see:
- Module overview: [Automation.lean](../Automation.lean) (parent module re-exports)
- Generated docs: Run `lake build :docs`
- Tactic development guide: [TACTIC_DEVELOPMENT.md](../../../docs/user-guide/TACTIC_DEVELOPMENT.md)

## Related Documentation

- [LEAN Style Guide](../../../docs/development/LEAN_STYLE_GUIDE.md)
- [Tactic Development](../../../docs/user-guide/TACTIC_DEVELOPMENT.md)
- [Implementation Status](../../../docs/project-info/IMPLEMENTATION_STATUS.md)

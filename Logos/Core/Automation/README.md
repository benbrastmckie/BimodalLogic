# Automation

Custom tactics and proof automation for TM bimodal logic.

## Submodules

- **Tactics.lean**: Custom tactics for modal and temporal reasoning
  - `apply_axiom`: Apply TM axiom by name
  - `modal_t`: Apply modal T axiom automatically
  - `tm_auto`: Comprehensive TM automation with Aesop (Phase 5)
  - `assumption_search`: Search for formula in context (Phase 6)

- **AesopRules.lean**: Aesop rule set for TM logic
  - TMLogic rule set declaration
  - Forward chaining for proven axioms (MT, M4, MB, T4, TA)
  - Apply rules for core inference (modus_ponens, modal_k, temporal_k)
  - Normalization rules for derived operators

- **ProofSearch.lean**: Bounded proof search infrastructure (planned)
  - Depth-limited search for derivations
  - Heuristic-guided proof search
  - Proof caching and memoization

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

- **Phase 4** ✓: `apply_axiom` (macro), `modal_t` (elab_rules)
- **Phase 5**: `tm_auto` with Aesop integration
- **Phase 6**: `assumption_search` with TacticM
- **Phase 7**: Bounded proof search (infrastructure only, 15-20 hours estimated)

## Building and Type-Checking

```bash
# Build automation module
lake build Logos.Core.Automation

# Type-check specific file
lake env lean Logos/Core/Automation/Tactics.lean
lake env lean Logos/Core/Automation/AesopRules.lean
lake env lean Logos/Core/Automation/ProofSearch.lean
```

## API Documentation

For detailed API documentation, see:
- Module overview: [Automation.lean](../Automation.lean) (parent module re-exports)
- Generated docs: Run `lake build :docs`
- Tactic development guide: [TACTIC_DEVELOPMENT.md](../../../Documentation/UserGuide/TACTIC_DEVELOPMENT.md)

## Related Documentation

- [LEAN Style Guide](../../../Documentation/Development/LEAN_STYLE_GUIDE.md)
- [Tactic Development](../../../Documentation/UserGuide/TACTIC_DEVELOPMENT.md)
- [Implementation Status](../../../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)

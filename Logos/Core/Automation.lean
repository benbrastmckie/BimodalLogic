import Logos.Core.Automation.Tactics
import Logos.Core.Automation.ProofSearch
import Logos.Core.Automation.AesopRules

/-!
# Logos.Core.Automation - Proof Automation

Aggregates all Automation components for the Core TM logic layer.

## Submodules

- `Tactics`: Custom tactics (apply_axiom, modal_t, tm_auto, assumption_search)
- `ProofSearch`: Native proof search functions (bounded_search, search_with_heuristics, etc.)
- `AesopRules`: Aesop rule set for TM logic automation

## Usage

```lean
import Logos.Core.Automation

example : ⊢ (□p → p) := by
  tm_auto  -- Uses Aesop with TM-specific forward rules
```
-/

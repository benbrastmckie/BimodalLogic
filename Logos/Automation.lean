import Logos.Core.ProofSystem
import Logos.Core.Semantics
import Logos.Core.Metalogic

-- Module components (to be implemented with meta-programming)
-- import Logos.Core.Automation.Tactics
-- import Logos.Core.Automation.ProofSearch

/-!
# ProofChecker Automation Module

This module provides proof automation tools for the ProofChecker library,
including custom tactics for modal and temporal reasoning and basic proof search.

## Main Components

- `Automation.Tactics`: Custom tactics for modal/temporal reasoning
- `Automation.ProofSearch`: Automated proof search with bounded depth

## Usage Example

```lean
import Logos.Core.Automation

example (p : Formula) : [p.box] ⊢ p.box.box := by
  sorry  -- Would use: modal_k_tactic
```

## Implementation Status

Phase 7 (Basic Automation) provides infrastructure for:
- Custom tactic definitions (requires meta-programming)
- Proof search framework (requires search algorithms)
- Automation examples and documentation

**Note**: Full tactic implementation requires LEAN 4 meta-programming,
which is deferred for specialized development iteration.

## References

* LEAN 4 Metaprogramming Book: https://github.com/leanprover-community/lean4-metaprogramming-book
* Mathlib4 Tactics: https://github.com/leanprover-community/mathlib4/tree/master/Mathlib/Tactic
-/

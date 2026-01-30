import Bimodal.Automation.Tactics
import Bimodal.Automation.ProofSearch
import Bimodal.Automation.SuccessPatterns
import Bimodal.Automation.AesopRules

/-!
# Bimodal.Automation - Proof Automation

Aggregates all Automation components for the Core TM logic layer.

## Submodules

- `Tactics`: Custom tactics including:
  - `modal_search`: Bounded proof search for TM derivability goals (RECOMMENDED)
  - `temporal_search`: Proof search optimized for temporal formulas
  - `propositional_search`: Proof search for purely propositional formulas
  - `apply_axiom`, `modal_t`: Basic axiom application tactics
  - `tm_auto`: Aesop-powered automation (has known issues, prefer modal_search)
  - `assumption_search`: Context assumption search
- `ProofSearch`: Native proof search functions with multiple strategies:
  - `search`: Unified interface with IDDFS, BoundedDFS, or BestFirst
  - `search_with_learning`: Pattern learning-enhanced search
  - `bestFirst_search`: Priority queue-based best-first search
  - `iddfs_search`: Iterative deepening with completeness guarantees
- `SuccessPatterns`: Pattern learning for proof search optimization
  - `PatternDatabase`: Records successful proof patterns
  - `PatternKey`: Formula structural features for pattern matching
  - `ProofStrategy`: Strategy types (Axiom, Assumption, ModusPonens, etc.)
- `AesopRules`: Aesop rule set for TM logic automation

## Usage

```lean
import Bimodal.Automation

-- Prove modal T axiom using modal_search
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search

-- Prove with modus ponens
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

-- Configure search depth
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search (depth := 5)

-- Temporal formulas (use temporal_search)
example (p : Formula) : ⊢ p.all_future.imp p.all_future.all_future := by
  temporal_search

-- Propositional formulas (use propositional_search)
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  propositional_search
```

## Tactic Selection Guide

- `modal_search`: General purpose, works on all TM derivability goals
- `temporal_search`: Prioritizes temporal rules, use for Fφ/Gφ formulas
- `propositional_search`: Disables modal/temporal K, use for purely propositional goals
- `tm_auto`: Legacy Aesop wrapper, has proof reconstruction issues

## Implementation (Task 315)

The proof search tactics work at the meta-level in TacticM, bypassing the Axiom Prop vs Type
issue by constructing proof terms directly via `mkAppM` rather than returning proof witnesses.

Search strategies (in order):
1. Axiom matching against all 14 axiom schemata
2. Assumption matching in context
3. Modus ponens decomposition (backward chaining)
4. Modal K rule (reduce □Γ ⊢ □φ to Γ ⊢ φ)
5. Temporal K rule (reduce FΓ ⊢ Fφ to Γ ⊢ φ)

## References

* [Tactics.lean](Automation/Tactics.lean) - Custom proof tactics
* [ProofSearch.lean](Automation/ProofSearch.lean) - Native search functions
* [SuccessPatterns.lean](Automation/SuccessPatterns.lean) - Pattern learning database
* [AesopRules.lean](Automation/AesopRules.lean) - Aesop rule configuration
-/

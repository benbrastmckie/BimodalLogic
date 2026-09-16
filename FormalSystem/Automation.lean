/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.UserTactics
import FormalSystem.Automation.Tactics.Commands
import FormalSystem.Automation.Tactics.PropDecide
import FormalSystem.Automation.ProofSearch.Core
import FormalSystem.Automation.ProofSearch.Strategies
import FormalSystem.Automation.SuccessPatterns
import FormalSystem.Metalogic.WeakCanonical.EFGameTactics
import FormalSystem.Automation.FormulaEnumerator
import FormalSystem.Automation.DatasetGenerator
import FormalSystem.Automation.DataExport
import FormalSystem.Automation.EnrichedCountermodel
import FormalSystem.Automation.DatasetAssembly
import FormalSystem.Automation.ProofStepExtractor
import FormalSystem.Automation.Normalization
import FormalSystem.Automation.InterestingnessMetrics
import FormalSystem.Automation.PrefilterSoundness
-- DatasetGeneratorMain, DatasetValidatorMain, and ProofStepExport define `main` (lean_exe targets)
-- and must not be imported through the umbrella; use them only via `lake exe` commands.

/-!
# FormalSystem.Automation - Proof Automation

Aggregates all Automation components for the Core TM logic layer.

## Submodules

- `Tactics`: Custom tactics including:
  - `modal_search`: Bounded proof search for TM derivability goals -- the single
    proof-search entry point. It replaced `temporal_search`, `propositional_search`
    and `tm_auto`, which differed from it only in `SearchConfig` weight fields that
    `searchProof` never read, and which have been removed.
  - `apply_axiom`, `modal_t`: Basic axiom application tactics
  - `assumption_search`: Context assumption search
- `ProofSearch`: Native proof search functions with multiple strategies:
  - `search`: Unified interface with IDDFS, BoundedDFS, or BestFirst
  - `searchWithLearning`: Pattern learning-enhanced search
  - `bestFirstSearch`: Priority queue-based best-first search
  - `iddfsSearch`: Iterative deepening with completeness guarantees
- `SuccessPatterns`: Pattern learning for proof search optimization
  - `PatternDatabase`: Records successful proof patterns
  - `PatternKey`: Formula structural features for pattern matching
  - `ProofStrategy`: Strategy types (Axiom, Assumption, ModusPonens, etc.)

## Usage

```lean
import FormalSystem.Automation

-- Prove modal T axiom using modal_search
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search

-- Prove with modus ponens
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search

-- Configure search depth
example (p : Formula) : ⊢ p.box.imp p := by
  modal_search (depth := 5)

-- Temporal formulas
example (p : Formula) : ⊢ p.allFuture.imp p.allFuture.allFuture := by
  modal_search

-- Propositional formulas
example (p q : Formula) : [p, p.imp q] ⊢ q := by
  modal_search
```

## Tactic Selection Guide

- `modal_search`: general purpose, and the only proof-search tactic. It works on all
  TM derivability goals, temporal and propositional ones included; there is no
  formula shape for which a different search tactic would do better.

## Implementation

The proof search tactics work at the meta-level in TacticM, bypassing the Axiom Prop vs Type
issue by constructing proof terms directly via `mkAppM` rather than returning proof witnesses.

Search strategies (in order):
1. Axiom matching against 42 of the 45 axiom schemata (the three Layer-9 Reynolds
   Dedekind axioms `prior_U_gap`, `prior_S_gap` and `sep` are outside the matcher's list)
2. Assumption matching in context
3. Modus ponens decomposition (backward chaining)
4. Modal K rule (reduce □Γ ⊢ □φ to Γ ⊢ φ)
5. Temporal K rule (reduce FΓ ⊢ Fφ to Γ ⊢ φ)

## References

* [Tactics.lean](Automation/Tactics.lean) - Custom proof tactics
* [ProofSearch.lean](Automation/ProofSearch.lean) - Native search functions
* [SuccessPatterns.lean](Automation/SuccessPatterns.lean) - Pattern learning database
-/

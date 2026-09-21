/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.UserTactics
import FormalSystem.Automation.Tactics.Commands
import FormalSystem.Metalogic.Decidability.Propositional.Tactic
import FormalSystem.Automation.ProofSearch.Core
import FormalSystem.Automation.ProofSearch.Strategies
import FormalSystem.Automation.SuccessPatterns
import FormalSystem.Metalogic.WeakCanonical.EFGameTactics
import FormalSystem.Automation.Normalization
-- This aggregator is LIBRARY-ONLY. It used to import eight tooling modules -- FormulaEnumerator,
-- DatasetGenerator, DataExport, EnrichedCountermodel, DatasetAssembly, ProofStepExtractor,
-- InterestingnessMetrics and PrefilterSoundness -- and was the single reason `lake build`
-- compiled any of them. They now live in `lean_lib BimodalTools`, outside `defaultTargets`, and
-- those eight import lines are gone: re-adding one would pull 14,750 lines of tooling back into
-- the published library's build closure. Check `B3` fails on any `import BimodalTools.*` under
-- `FormalSystem/`, this file included. Tooling reaches the library, never the other way round.

/-!
# FormalSystem.Automation - Proof Automation

Aggregates the Automation components of the Core TM logic layer. Library only: the dataset,
export and benchmark modules this file used to import are now `lean_lib BimodalTools`, outside
`defaultTargets`. See `BimodalTools/README.md` for what left and why.

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
- `Normalization`: the derived-operator unfold and fold lemmas, reached directly rather than
  through this aggregator. The simp sets it tags them into, and the `@[tmLemma]` attribute the
  derived-lemma database is built from, are declared in `FormalSystem/Tactic/Attr.lean` at
  layer 0 and reach every module through `FormalSystem/Init.lean`. They used to be three modules
  in this directory (`NormalizationAttr`, `TruthNormAttr`, `LemmaDB`), which is why `Syntax/`,
  `Semantics/`, `ProofSystem/` and `Theorems/` each carried an upward import into `Automation/`.

Not here any more: `FormulaEnumerator`, `DatasetGenerator`, `DataExport`, `EnrichedCountermodel`,
`DatasetAssembly`, `ProofStepExtractor`, `InterestingnessMetrics` and `PrefilterSoundness`. Those
eight imports were this file's tooling half and the sole reason `lake build` compiled any of it;
they are `BimodalTools.*` now.

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
1. Axiom matching against 27 of the 29 axiom schemata (the two Layer-9 Reynolds
   Dedekind axioms `prior_U_gap` and `sep` are outside the matcher's list); the derived
   schemata (time-reflection mirrors, modal 4 and B) are reached through `@[tmLemma]`
2. Assumption matching in context
3. Modus ponens decomposition (backward chaining)
4. Modal K rule (reduce □Γ ⊢ □φ to Γ ⊢ φ)
5. Temporal K rule (reduce FΓ ⊢ Fφ to Γ ⊢ φ)

## References

* [Tactics.lean](Automation/Tactics.lean) - Custom proof tactics
* [ProofSearch.lean](Automation/ProofSearch.lean) - Native search functions
* [SuccessPatterns.lean](Automation/SuccessPatterns.lean) - Pattern learning database
-/

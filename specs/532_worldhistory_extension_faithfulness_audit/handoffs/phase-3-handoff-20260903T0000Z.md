# Phase 3 handoff — truthAt_map derived from alignedCorr

- **Next action**: Phase 5 (docstring hygiene across Truth/WorldHistory/PartialHistory/FlowFrame/FwdRecPeriodicity), then Phase 6 closure.
- **State**: `IntTransfer.lean` has `alignedCorr` immediately before `truthAt_map`; `truthAt_map` is a one-line term; module docstring's design-decision, trap, and main-results bullets updated. Zero `induction φ` in the file.
- **Gates**: full `lake build` 2520 jobs green; invariants ALL CHECKS PASSED; axioms unchanged (`Classical.choice` was already present).

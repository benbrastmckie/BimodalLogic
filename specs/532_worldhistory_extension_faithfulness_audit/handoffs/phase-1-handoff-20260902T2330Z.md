# Phase 1 handoff — TruthCorr landed, truthAt_of_truthIso derived

- **Next action**: Phase 4 (record re-pin, independent) then Phases 2, 3 (both consume `TruthCorr`).
- **State**: `FormalSystem/Semantics/Truth.lean` has `TruthCorr` + `Truth.truthAt_of_truthCorr` placed between `end Truth` (truth_norm block) and `## Time-Shift Preservation`; `TruthIso.toCorr` sits after `structure TruthIso` (outside `namespace Truth`, so `I.toCorr` dot-notation works); `truthAt_of_truthIso` is a term-mode one-liner.
- **Gates**: full `lake build` 2520 jobs green; invariants ALL CHECKS PASSED; axioms propext/Quot.sound only.
- **Decisions**: `TruthIso.toCorr` uses `Truth.atom_iff_of_domain` qualified (not inside `namespace Truth`). One docstring sentence in `truthAt_of_truthAntiIso` re-pointed at `truthAt_of_truthCorr`.
- **Trap noted**: a concurrent `lake env lean` axiom check during a full build produced a spurious `.olean` "no such file" error; re-running the build was enough. Do not overlap them.

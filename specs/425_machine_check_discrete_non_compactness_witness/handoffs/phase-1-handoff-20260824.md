# Phase 1 handoff — task 425

**Next action**: Phase 2 — create `FormalSystem/Metalogic/DiscreteNonCompactness.lean` with
`import FormalSystem.Metalogic.StrongCompleteness`, transcribe `truthAt_next_iff` and
`truthAt_next_iterate` from report §3 Layer 1, register in `FormalSystem/Metalogic.lean`.

**State**: `SatisfiableDiscreteSet` and `CompactDiscrete` landed in
`FormalSystem/Metalogic/SetConsequence.lean` verbatim from report §3 Layer 0, under a new
`/-! ## Satisfiability and compactness for FrameClass.Discrete` section heading. Module
docstring widened to name Discrete and to record the open-vs-refuted asymmetry.

**Verification**: `lake build FormalSystem.Metalogic.SetConsequence` green;
`lake build FormalSystem.Metalogic.StrongCompleteness` (the sole direct dependent) green.
No import change was required. Both names were tree-fresh before the edit.

**Deviations**: none.

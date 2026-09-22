# Phase 2 handoff — task 654

- **Phase**: 2 (RigidityReal.lean — the Q2 headline) — [COMPLETED]
- **Next action**: Phase 3 — add `Mathlib.Analysis.Real.Cardinality` and
  `FormalSystem.Semantics.Frames.Standard` to `RigidityReal.lean`, then transcribe the Q3
  block and the padded-clock block from `probes/01_clock-frames.lean`.
- **State**: `FormalSystem/Semantics/Correspondence/RigidityReal.lean` green under
  `lake build --wfail`, 1 abbrev + 4 theorems, 185 lines, zero warnings.
  `lean_verify FormalSystem.Semantics.FrameOver.static_of_countable` reports
  `[propext, Classical.choice, Quot.sound]`.
- **Decisions**: the narrowed import list (`Extension`, `Correspondence.Rigidity`,
  `ForMathlib.Topology.Sierpinski`) suffices; no `import Mathlib`.
- **Deviations**: none.

# Phase 3 Handoff — Task 641

- **Next action**: Phase 4 — the frame-class-sensitivity section (`ggFml`, `ggAtDense`, the ℤ
  blip countermodel, `ggNotBase`, `ggNotZTime`). The compiled body is in the session scratchpad
  at `ProbeA.lean`.
- **State**: tableau leg appended and green. **Scope Hypothesis confirmed**: `by decide` on
  `isValid tFml = true` costs no measurable time — module build stayed at ~1.2 s, far inside the
  plan's ~10 s threshold, so no formula shrink and no `native_decide` is needed.
- **Axiom audit so far**: `pAtom`/`pF`/`tFml` no axioms; `tByHand`/`boxedT`/`tByAuto` `[propext]`;
  `tValid`/`tDerivable`/`tIsValid`/`tValidViaTableau` at the standard three.
- **Deviations**: none in this phase. `isValid_sound` is the declaration body (the verified
  shape); `sound_of_isValid` is named in the docstring as the bridge it wraps, which is what the
  task description asked to be visible.

# Phase 16 handoff — Independence

**Status**: [COMPLETED]. Build 0, test build 0, invariants ALL CHECKS PASSED, zero sorry.

## Immediate next action
Phase 17 — `Examples/TemporalStructures.lean`.

## Carry-forward
- The binder criterion is now settled and stated in the plan's Phase 16 Record. Apply it in
  Phase 17: `intTimeFrame`/`intNatFrame`/`intBoolFrame` become `FrameOver intOrder`;
  `genericTimeFrame`/`genericNatFrame` take `(D : TemporalOrder)` (their `D` is explicit and used
  only as a duration order), with `[SuccOrder ↑D] [NoMaxOrder ↑D]` side conditions.
- Phase 17 measured scope: 55 occurrences in `TemporalStructures.lean`, but only **5** are type
  ascriptions (lines 78, 123, 225, 331, 380) plus 3 prose. The other ~47 are
  `ParamTaskFrame.{interpolates_of_total, serial_of_total, limit_of_subsingleton,
  spherical_of_subsingleton, *_of_permissive, nullity, spherical_of_finite}` namespace
  references — Phase 20's relocation, not Phase 17's.
- The only cross-file consumer is `Tests/BimodalTest/Semantics/TaskFrameTest.lean:65`
  (`customFrame : ParamTaskFrame Int := … .intBoolFrame`), which Phase 19 owns.

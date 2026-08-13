# Phase 10 handoff — task 420

**Immediate next action**: Phase 11 — axiom lemmas for `intTimeFrame` (TemporalStructures.lean:77),
`intNatFrame` (:90), `genericTimeFrame` (:157), `genericNatFrame` (:169), citing Phase 10's helpers.

**State**: `lake build` green, exit 0, 2331 jobs. Phases 1-10 landed and committed.

**Key decisions**
- Sub-step 10.0 relocated `Spherical` / `Serial` / `Interpolates` from `FrameAxioms.lean` into
  `TaskFrame.lean` (names unchanged, zero consumer churn). Forced: a structure field's type may
  only mention earlier declarations, so the Props had to precede the eventual field additions.
  Phase 14 will still need a second, purely mechanical hoist — the apparatus and the three Props
  currently sit *after* the `TaskFrame` structure (TaskFrame.lean:177) and must move *before* it.
  Do that as a separate green commit BEFORE opening the atomic batch.
- Three reusable relation classes cover every non-shift site: total-on-subsingleton, permissive
  (`d ≠ 0 ∨ w = u`), equality. Each helper takes class membership as an `Iff` hypothesis, so a
  site discharges with `fun _ _ _ => Iff.rfl`.
- `natFrame`'s `[SuccOrder D] [NoMaxOrder D]` binder change is deferred to Phase 14 (the plan's
  sanctioned second branch). Only propagation target is `WorldHistory.universalNatFrame`, which
  has zero consumers.

**Deviations**: recorded in the plan's Phase 10 `**Deviations**` block.

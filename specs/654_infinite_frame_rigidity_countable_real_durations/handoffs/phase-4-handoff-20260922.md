# Phase 4 handoff — task 654

- **Phase**: 4 (`ratClock_not_static` into RigiditySharpness.lean) — [COMPLETED]
- **Next action**: Phase 5 — documentation wiring (Rigidity.lean cross-reference,
  Correspondence README rows and Key Results bullet, `docs/theorem-index.md` row).
- **State**: `RigiditySharpness.lean` 216 lines, green under `lake build --wfail`, zero
  warnings. `lean_verify FormalSystem.Semantics.Rigidity.ratClock_not_static` reports
  `[propext, Classical.choice, Quot.sound]`. `git diff --stat` lists it as the only file
  changed by this phase.
- **Decisions**: `ratOrder` is a plain `abbrev`, not `noncomputable` — `TemporalOrder.of ℚ`
  is computable. The theorem is therefore stated as
  `¬ Static (translationFrame ratOrder).TaskRel`, which is reducibly the Challenge block's
  `¬ Static (translationFrame (TemporalOrder.of ℚ)).TaskRel`.
- **Deviations**: the `noncomputable` drop above, annotated inline on the plan checklist item.

# Phase 4 handoff — task 667

- **Next action**: Phase 5 — write `Tests/BimodalToolsTest/TableauBridgeTest.lean` (rows A–E) and
  add its import to `Tests/BimodalToolsTest.lean`.
- **State**: Phases 1–4 complete and committed. `lake build BimodalTools` green.
- **Measured values to pin** (from `lake env lean` on the built library):
  - `evalBranchGates (p → q) .Base` = all eight `true`, `gated = true`
  - `evalBranchGates (p → q) .ZTime` = `regionLabel = false`, `temporalWitness = false`,
    other six `true`, `gated = false`
  - `parseFrameClass "RTime" = .ok .RTime`, `"Discrete" = .ok .ZTime`,
    `"Bogus" = .error "unknown frame_class: 'Bogus' (expected one of: Base, Dense, ZTime, Discrete, RTime)"`
  - `parseRequest` on a line with `"frame_class": "Bogus"` = the same `.error`
  - valid arm of `decideResponseBody` carries no `"gates"` key; response bytes for
    `tableau_decide` at `.Base` are otherwise unchanged from pre-split baseline
- **Decisions**: `"gated"` is the eight-way conjunction; JSON keys are snake_case and named after
  the Lean gate functions. `handleCountermodel` inlines one `buildTableau φ fuel fc` re-run
  instead of calling `extractCountermodelData` (which has no `fc` parameter).
- **Deviations**: recorded inline on the plan's Phase 3/4 checklist items.

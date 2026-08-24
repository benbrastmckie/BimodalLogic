# Phase 1 handoff — verdict reproduced, ceiling bracketed

**Next action**: Phases 2-4 are cleared. No divergence from the research report.

**Measured state (all via `lake env lean`, working tree at `3ff158bad`)**:
- `decide ((G p) → □(G p))` = `(false, true, false, false, false)` → `.invalid`;
  `getCountermodel?.isSome = true`.
- Fuel ceiling **25**, bracketed both sides: `buildTableau φ n .Base` is `none` for all
  `n ∈ [0,24]`, `hasOpen` with a stationary 40-formula branch for all `n ∈ [25,1000]` tested.
- Sub-ceiling `none` attributed to fuel exhaustion inside `expandBranchWithFuel` (survives
  `maxBranches := 10^9`), not the `maxBranches` arm and not the unsaturated arm.
- `F(G p)`: inner loop stationary at 21 formulas for every fuel 25…4096, `findUnexpanded` always
  `some _`; residue `F(G p) @ (0,4)` before `saturateBlocked`, `T(F ¬p) @ (0,4)` after.
- Rows A and C both `((false, true, false, false, false), true)`.
- `soundFuel' φ = 1048576`, `worldFuel' φ 1 = 1099512676352`, `|closure φ| = 8`.

**Artifact**: `reports/02_measured-constants.md` (measurement table + reproduction sources).

**Decisions**: none deviating from plan. **Deviations**: none.

**Environment note**: several other agents in this session run concurrent `lake build`s; the
olean tree is repeatedly invalidated mid-run. Rebuild before elaborating any file.

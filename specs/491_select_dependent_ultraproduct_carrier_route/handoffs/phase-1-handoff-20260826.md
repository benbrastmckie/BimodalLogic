# Phase 1 handoff — carrier construction landed as a compiled probe

**Next action**: Phase 2 — add `import BimodalTest.Semantics.DependentUltraproductProbe` to
`Tests/BimodalTest.lean`, run `lake build BimodalTest` and the default `lake build`, append the
decision record to the report, and update task 492's description in `specs/state.json`.

**State**: `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` exists (283 lines) and
builds clean as `BimodalTest.Semantics.DependentUltraproductProbe` in 1.4s under
`theoryLeanOptions` (`autoImplicit := false`, `pp.unicode.fun := true`). Not yet imported from
`Tests/BimodalTest.lean`.

**Measurements**:
- No `autoImplicit := false` fallout at all — the prototype's binders were already explicit.
- 0 `sorry`. No new axiom.
- Axiom profiles, verbatim from the build:
  - `BimodalTest.DependentUltraproductProbe.shiftSetOnUD` → `[propext, Classical.choice, Quot.sound]`
  - `BimodalTest.DependentUltraproductProbe.shU_add` → `[propext, Classical.choice, Quot.sound]`
  - `BimodalTest.DependentUltraproductProbe.instDenselyOrderedUD` → `[propext, Classical.choice, Quot.sound]`
  These match report §2.5 exactly.
- Declaration set is identical to the prototype's: 18 named declarations plus 5 instances
  (3 anonymous, 2 binder-guarded) = the 23 the plan's Scope Hypothesis enumerates. No addition.

**Key decisions**: namespace `UProto` → `BimodalTest.DependentUltraproductProbe`; the mathematical
content is verbatim; `set_option linter.unusedSectionVars false` kept file-scoped.

**Deviations**: verification used the scoped `lake build <module>` rather than the plan's
`lake env lean <file>`, because `lake env lean` does not apply the library's `leanOptions` and
applying them is exactly what this phase measures.

**Environment note**: `lake-build-guard.sh` passes everything after `--` straight to `lake`, so
the lake subcommand must be included: `... build --timeout 1800 -- build <target>`. It also
replays a concurrent sibling's shared build result unless `--no-share` is passed; the first
attempt here silently returned a sibling's default-target build. Both matter for Phase 2.

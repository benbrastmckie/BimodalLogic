# Phase 11.38 handoff — the jump clauses' statement layer

**Status**: Phase 11.38 `[COMPLETED WITH EXCLUSIONS]` (plan v24). Not entered: 11.33–11.35, 11.39, 11.40.

**Immediate next action**: Phase 11.39 — attempt the path forth with a whole-row correspondence
(`exists_rowLinked_path`) and the `untl` case of `truth_iff_of_lnkRow`, against `LnkRow` as landed.

**Current state**:
- `LadderStepFrag.lean` carries `FwdJump`, `BwdJump`, `LnkRow a b g g' t t'` (two-positioned, by
  well-founded recursion on `a + b`; unfold with `rw [LnkRow]`), `LnkRow.zero/.symm/.mono/.succ/
  .pred/.toLnk`, `exists_rowLinked_path_zero`.
- The `untl` truth clause over `LnkRow` is immediate from the definition (the relation IS the
  clause's condition); the whole cost is the path forth.
- All gates green: guarded `lake build` (2976 jobs) and `build BimodalTest` (3044 jobs) exit 0,
  `check-module-invariants.sh`, `readme-lint.sh`, `check-evidence-probes.sh` (64 probes),
  `verify-deploy.sh` (15 checks).

**Key decisions / findings**:
- The path forth's hypothesis is NOT `Zrel a b`: at `mixC a k` two `Zrel a (k + 2)`-related states
  have different cells (argued from `mixC_mem`/`mixC_not_mem`, not compiled). Candidate hypothesis
  `Zrel (a + b + 1) (a + b)`. A round relying on the refutation should compile it first.
- The restated `⊡` clause compiled at budget `(0, 0)` only; at a positive budget it is the path
  forth itself.

**Deviations**: the `⊡`-clause task is altered as above (sanctioned by the task's own text); the
generated inventory blocks of `README.md` and `FormalSystem/Metalogic/README.md` and the
`RaySummary/README.md` row were refreshed (line count), which the phase's file list did not name.

**Record**: `records/round-24-jump-clause-statements.md`.

# Implementation Summary: Task #632

- **Task**: 632 - BimodalTools library split
- **Status**: [COMPLETED]
- **Started**: 2026-09-20T00:00:00Z
- **Completed**: 2026-09-20T00:00:00Z
- **Effort**: ~4 hours (plan estimate: 11.5)
- **Dependencies**: 630 (landed)
- **Artifacts**: plans/01_bimodaltools-library-split.md, reports/01_bimodaltools-library-split.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The 25 tooling modules (14,527 lines) under `FormalSystem/Automation/` and
`FormalSystem/Metalogic/Decidability/TraceExport.lean` are now `lean_lib BimodalTools`, declared
outside `defaultTargets`, with the 8 tooling tests in `lean_lib BimodalToolsTest`. The 12 tooling
`lean_exe` targets re-rooted under `BimodalTools.*` with their names unchanged. A new `B3`
invariant asserts the split is one-way: `FormalSystem` never imports `BimodalTools`, while the
converse direction stays sanctioned and deliberately ungated.

All nine plan phases completed in order. The plan's central commitment — widen every gate's scan
root **before** anything moves, so a narrowing is loud rather than silent — was executed and paid
off twice: the widening itself surfaced a forward reference in `PUBLICATION_REFACTOR.md`, and the
post-move run of `typst-sync-check.sh` caught 22 identifier citations that had just left its
single-root scan.

## What Changed

**New Lake targets and roots**

- `lakefile.toml` — `[[lean_lib]] BimodalTools` (repo root, outside `defaultTargets`) and
  `[[lean_lib]] BimodalToolsTest` (`srcDir = "Tests"`); 12 `lean_exe` roots re-rooted
  `FormalSystem.Automation.*Main` -> `BimodalTools.*Main`, target names unchanged.
- `BimodalTools.lean` — new aggregator importing the **13 non-`Main`** modules. No `*Main`
  module: each declares a root-namespace `main` and two cannot share one environment.
- `Tests/BimodalToolsTest.lean` — new aggregator importing 6 moved tests plus the new
  `EnumeratorCountsTest`. `FormulaMutatorTest` and `ProofFirstTests` stay unaggregated and
  C6-manifested, for the same `main`-collision reason they were excluded before the split.
- `BimodalTools/README.md`, `Tests/BimodalToolsTest/README.md` — new, with generated inventories.

**Relocated (by `scripts/move-modules.py`, one `git mv` each so `git log --follow` crosses it)**

- 24 modules `FormalSystem/Automation/*.lean` -> `BimodalTools/*.lean`
- `FormalSystem/Metalogic/Decidability/TraceExport.lean` -> `BimodalTools/TraceExport.lean`
- 8 tests `Tests/BimodalTest/{Automation/,}*.lean` -> `Tests/BimodalToolsTest/*.lean`
- 236 citation rewrites across 46 files (80 import lines, 125 dotted, 22 slash-path, 9 namespace)

**Namespace work** — 18 dotted namespace rows via the map; 6 files hand-edited out of the shared
bare `FormalSystem.Automation` namespace (a bare map row would have rewritten the staying
library's own namespace); 4 moved tests whose namespace did not match their module name renamed
under `BimodalToolsTest.*` by hand.

**Gates widened** (all landed and negative-tested before the move)

- `scripts/check-module-invariants.sh` — scan roots widened for B2, C3, C4/C5/C6/C7/C8 (via a
  shared `LIB_ROOTS`/`TEST_SRC_ROOTS` table), C15, C17, C19, C20, C23, C25N, C26, C27, C29, C30.
  New `B3` check. C6 manifest line for `ProofFirstBenchmark` deleted (the aggregator makes it
  reachable). C16 and C28 needed no edit, and why is now recorded in-file at each check.
- `scripts/CheckInitImportsMain.lean` — C24's `FormalSystem`-root filter recorded as a deliberate
  scope decision, not an oversight.
- `scripts/typst-sync-check.sh` — Check 1 given a colon-separated `LEAN_SRC_ROOTS` list.
- `scripts/move-modules.py` — `MODULE_ROOT_DIRS` entry for `BimodalToolsTest`, and `resolve_move()`
  so a file-granular map row actually moves (see Decisions).
- `scripts/measure-refactor-partitions.py` — the unconditional `TraceExport` append guarded on the
  module existing.
- `.github/workflows/ci.yml` — copyright and README steps widened to `FormalSystem BimodalTools`;
  two new steps, `lake build BimodalTools` and `lake build BimodalToolsTest`, after the exe-root
  step so they reuse the warm cache.

**Prose and records**

- `FormalSystem/Automation/README.md` — rewritten opening (the ML half is gone) and a new
  `## Decision: SuccessPatterns stays, undivided` section that also records the supersession of
  PUBLICATION_REFACTOR Phase 4's "cut `ProofSearch.Core -> SuccessPatterns`" bullet.
- `docs/development/MODULE_INVARIANTS.md` — new `B3` row; six scan-root descriptions corrected.
- `FormalSystem/Metalogic/Decidability/README.md` — `TraceExport.lean` row and flowchart mention
  removed, with a note saying where it went and that the certificate *types* stay.
- 14 bare-form `Automation/<Module>.lean` citation sites closed across `typst/`, `docs/`,
  `scripts/`, `Tests/` and `BimodalTools/` (the tool does not rewrite these by design).
- `Tests/BimodalTest/Automation/NormalizationTest.lean` — two enumerator-dependent regions
  extracted to `Tests/BimodalToolsTest/EnumeratorCountsTest.lean`; the rest stayed so library
  normalization coverage remains inside `lake test`.

## Decisions

- **`move-modules.py` could not move a single module, and said nothing.** `move_trees` `git mv`'d
  each mapping's extension-free path stem, which resolves only for a directory subtree — the shape
  the Boneyard relocation it was built for happened to have. All 33 file-granular rows here
  reported `skip ... (not present)`, and the first dry run moved **0 paths** while cheerfully
  reporting 236 citation rewrites. Fixed with `resolve_move()`, which resolves a stem to a
  directory or to `stem + ".lean"`, preferring the directory.
- **The `open` direction the plan anticipated was the minor one.** The plan named 5 modules
  needing `open FormalSystem.Automation`. The larger need was the opposite, `open BimodalTools`,
  at 13 sites — every file outside `namespace BimodalTools` that referenced a declaration from one
  of the 6 hand-edited modules. None of it was visible until the 12 exe roots were built
  individually: `lake build`, `lake build BimodalTools`, `lake build BimodalToolsTest` and
  `lake test` were **all green** while 5 of the 13 roots did not compile. C25 is what caught it.
- **`SuccessPatterns` stays in the library, undivided** — no IO/JSON seam to split on, live
  library call sites in `ProofSearch/`, and the tooling reaches its vocabulary the sanctioned way.
  Recorded in `FormalSystem/Automation/README.md`.
- **Neither new CI build step carries `--wfail`.** The tooling tree carries warnings the library
  does not; a hard stop would gate this split on that burndown. C28's per-file warning budget is
  the compensating control and reads Lake's trace store, so it needed no widening. Recorded at
  C28's site.
- **C6's stale-manifest deletion had to move from Phase 8 to Phase 6.** The moment
  `BimodalTools.lean` aggregated the 13 modules, `ProofFirstBenchmark` became reachable and C6
  failed; Phase 6 could not close green without it.
- **The `typst-sync-check.sh` "sorry-total" mismatch was deliberately left alone.** Regenerating
  it would delete a true statement about archived material the generator can no longer see.

## Plan Deviations

- **Phase 1 / Phase 4** altered: `readme-lint.sh` exits 1 before and after (21 pre-existing broken
  `../Boneyard/...` links). Achievable evidence substituted: output byte-identical to the
  unwidened run apart from the README count.
- **Phase 2** altered: C16 and C28 (both on the plan's widening list) needed no edit, and B2, C15
  and C23 (absent from it) did. The widening was not a no-op — C5 caught a forward reference in
  `PUBLICATION_REFACTOR.md`, closed with a temporary self-deleting allowlist entry removed in
  Phase 6. A second negative test was added beyond the plan's one.
- **Phase 5** altered: 18 namespace rows, not 19; 14 bare-form sites, not 11; the bare-form audit
  line is near-vacuous for a file-granular relocation; `move-modules.py` needed the
  `resolve_move()` fix above.
- **Phase 6** altered: the predicted `measure-refactor-partitions.py` rewrite did not happen (the
  literal is an f-string), though the phantom-row hazard was real for a different reason; the
  three aggregator re-points each needed `Tactics.Commands` too; the `open BimodalTools` work
  above.
- **Phase 7** altered: `typst-sync-check.sh` Check 1 went 10 -> 32 violations and was repaired back
  to baseline; `MODULE_MAP_MISMATCHES` taken 7 -> 0 by regeneration; four prose repairs beyond the
  plan's list.
- **Phase 8** altered: the C6 manifest line was deleted in Phase 6 and in
  `scripts/module-invariants-manifest.txt`, not in the harness script the plan named.
- **Phase 9** altered: Acceptance 1 asserted by deleting the build outputs and re-running a default
  build rather than by `lake clean`; C7's counts changed by exactly the +3 files this task adds,
  which is the correct predicate rather than "unchanged".

## Verification

- Build: **Success**. `lake build` (2,656 jobs), `lake build BimodalTools` (1,445),
  `lake build BimodalToolsTest` (1,448), `lake test`, and all **13** `lean_exe` roots individually.
- Sorry count: **0** (structural-sorry grep over `FormalSystem/` + `BimodalTools/`; `PASS C3`).
- Vacuous count: **0** introduced. One pre-existing match,
  `FormalSystem/Examples/TemporalStructures.lean:481`, present at the pre-task commit and untouched.
- Axiom count: **12 before, 12 after** across `FormalSystem/`, `Tests/` and `BimodalTools/` `.lean`
  files — unchanged. All 118 `'X' depends on axioms:` baseline rows diff clean against `9dfbdd97f`
  and `FormalSystem/MainResults.lean` is byte-identical; `move-modules.py` rewrote 0 axiom
  baselines. `PASS C2`, `PASS C14`.
- Tests: **Passed** (`lake test` exit 0; the retained `NormalizationTest.lean` still carries 49
  `normalizeFormula` occurrences and no `BimodalTools` reference).
- Invariant harness: `bash scripts/check-module-invariants.sh` (full, with build) reports
  **0 FAIL**, `PASS B3` included. One reporting-only `TODO C16` (170 findings across 13 of 16
  non-`FormalSystem` roots, `ENFORCE_C16_ROOTS=0`), which is pre-existing debt now counted over 16
  roots instead of 15.
- Acceptance 1 — a default `lake build` creates nothing under `.lake/build/lib/lean/BimodalTools`
  (0 `.olean`; directory absent).
- Acceptance 2 — `PASS B3`, negative-tested in both halves (an `import` under `FormalSystem/`, and
  a bare mention in `FormalSystem.lean`).
- Acceptance 3 — `lake build BimodalToolsTest` exit 0, plus the new CI step.
- Acceptance 4 — harness 0 FAIL.
- `measure-refactor-partitions.py automation-partition` reports the tooling set as **0 modules,
  0 lines**, with no phantom `TraceExport` row.
- `lake_targets.py exe-roots` lists all 12 tooling roots under `BimodalTools.*`, names unchanged.
- Other gates: `check-copyright-headers.sh --strict FormalSystem BimodalTools` exit 0,
  `check-metalogic-cycles.sh` exit 0, `check-evidence-probes.sh` exit 0.
- Files verified: Yes.

## Impacts

- A plain `lake build` no longer elaborates 14,527 lines of dataset/ML/benchmark tooling. The
  published `FormalSystem` library is what `defaultTargets` builds, and `B3` keeps it that way.
- Two new CI steps (~1,445 and ~1,448 jobs, both on the warm cache from the exe-root step) are the
  price of keeping the tooling compiled now that `lake build` does not reach it.
- `scripts/move-modules.py` can now relocate individual modules, not only whole subtrees — the
  next module-level refactor does not have to rediscover that gap.
- PUBLICATION_REFACTOR.md Phase 4's `SuccessPatterns` bullet is a documented no-op.
- Task 604 depends on this task and is unblocked.

## Follow-ups

- **`scripts/readme-lint.sh` exits 1 on `main`, and CI's "Check README health" step is red.** 21
  broken references, every one a `../Boneyard/...` relative link in a `FormalSystem/**/README.md`
  left one directory level short when the archive moved to the repository root. Pre-existing,
  outside this task's scope, not fixed here. The remedy is mechanical: each needs one more `../`.
  This is the same class of defect as the historical-statement flattening below — a relocation's
  bare-form citations are exactly what `move-modules.py` does not rewrite, by design.
- **`scripts/typst-sync-check.sh` exits 1 for one pre-existing reason**:
  `sorry-total: committed=4 live=0` on the row labelled "WeakCanonical/ (archived,
  Boneyard/Kamp/)". The generator's scan root no longer reaches the archive, so regenerating would
  delete a true statement rather than refresh a stale one. Belongs with whoever owns the archive
  relocation.
- **`TODO C16` is at 170 findings across 13 of 16 lakefile roots**, reporting-only behind
  `ENFORCE_C16_ROOTS=0`. The split neither created nor reduced this debt; it now spans two more
  roots.
- Consider whether the two new CI steps should adopt `--wfail` once the tooling warning count is
  burned down. The decision and its trigger are recorded at C28 in
  `scripts/check-module-invariants.sh`.

## References

- `specs/632_bimodaltools_split/plans/01_bimodaltools-library-split.md`
- `specs/632_bimodaltools_split/reports/01_bimodaltools-library-split.md`
- `docs/development/PUBLICATION_REFACTOR.md` (Phase 3, discharged; Phase 4 bullet superseded)
- `BimodalTools/README.md`, `Tests/BimodalToolsTest/README.md`
- `FormalSystem/Automation/README.md` (`SuccessPatterns` decision record)

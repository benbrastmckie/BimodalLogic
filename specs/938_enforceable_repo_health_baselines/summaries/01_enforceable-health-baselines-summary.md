# Implementation Summary: Task #938

- **Task**: 938 - Convert the repository's measured-but-unenforced health signals into pinned baselines that block regressions
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T00:12:06Z
- **Completed**: 2026-11-19T05:05:00Z
- **Effort**: ~5 hours
- **Dependencies**: None. Concurrent sibling task (CI/Lake build cache, plan phase) shared this working tree throughout; no file overlap occurred.
- **Artifacts**: plans/01_enforceable-health-baselines.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Three already-measured, advisory-only repo-health signals (README verification dates, three
un-gated C20 citation sub-counts, and the C16 env_linter sweep over every non-`FormalSystem`
lakefile root) are now each pinned to a committed, keyed, ratchet-only baseline and gated by a
check that fails on an increase above that baseline. All six phases of the plan landed; every
gate exits 0 on the unmodified tree, and every falsification arm was observed to fail with a
non-zero exit and then pass again after reverting the seed.

## What Changed

- `scripts/readme-lint.sh` — added `ENFORCE_README_DATES` (default 1); Check 4 now diffs the
  live stale/missing-date set against `scripts/readme-date-baseline.txt` and fails on a new
  finding (`STALE_NEW`/`NODATE_NEW`), while reporting stale-row pruning candidates.
- `scripts/readme-date-baseline.txt` — new; 67 pinned rows (`<class> <path> <stamp>`) covering
  the union of the default `FormalSystem` root and the `FormalSystem BimodalTools` root CI
  invokes.
- `scripts/check-module-invariants.sh` —
  - C20: added a fourth assertion gated by `ENFORCE_C20_RESIDUAL` (default 1), pinning the
    residual/unverifiable-declaration/unverifiable-filename sub-counts per citer file against
    `scripts/c20-residual-baseline.txt`, with a `C20_RESIDUAL_EMIT=1` generator mode.
  - C16: the second half now writes each root's `runLinter` log and hands the set to
    `scripts/c16_roots_baseline.py` in compare mode, mapping its exit codes (0/1/2) onto
    pass/fail(when enforced)/fail(unconditional); `ENFORCE_C16_ROOTS` flipped from 0 to 1. The
    header's dated per-root table was replaced with a pointer to the generated baseline, and the
    local/CI asymmetry (CI runs `--no-build`, so this half never executes in CI) is now stated
    explicitly.
- `scripts/c20-residual-baseline.txt` — new; 98 pinned per-citer-file rows (145 residual + 39
  unverifiable-declaration + 30 unverifiable-filename).
- `scripts/c16_roots_baseline.py` — new; parses `lake exe runLinter <root>` logs into
  `(root, module, linter)` counts, with `--update`, `--list`, and a default compare mode
  (exit 0/1/2), disposition-row discipline per linter class, and a root-excuse mechanism.
- `scripts/c16-roots-baseline.txt` — new; 98 pinned rows, 231 findings across 15 of 17
  *measurable* roots.
- `scripts/c16-roots-unmeasurable.txt` — new; excuses `BimodalToolsTest` from the sweep's
  anti-silence exit-2 guard, loudly (an INFO line every run), because its own build fails for a
  pre-existing, separately-owned reason (see Decisions below).
- `docs/development/MODULE_INVARIANTS.md` — amended the `ENFORCE_C16_ROOTS` "Adding a Check"
  paragraph to state the pinned-ceiling rule (not "wait for zero"); added paragraphs for
  `ENFORCE_C20_RESIDUAL` and `ENFORCE_README_DATES`; stated the C16 local/CI asymmetry; recorded
  all six negative tests in the section's established narrative form.
- `scripts/README.md` — added inventory rows for all four new data files plus the new generator
  script.

## Decisions

- **The C16-roots baseline is a new keyed file, not an extension of `scripts/nolints.json`**
  (plan Decision 1): `runLinter --update` rewrites `nolints.json` wholesale and grandfathering a
  finding there would make it stop being reported, hiding the exact debt this task exists to pin.
- **A README baseline row pins the stamped date, not only the path** (plan Decision 2): a
  presence-only row would permanently exempt a README from ever gating again; pinning the stamp
  makes a later refresh automatically un-grandfather that README.
- **`BimodalToolsTest` is excused from C16-roots measurement via a new
  `scripts/c16-roots-unmeasurable.txt`, on the `scripts/module-invariants-manifest.txt` (C6)
  precedent, rather than silently treated as zero findings.** Its own build fails with an
  "Ambiguous term closureList" error between two same-named declarations
  (`BimodalTools.CertificateImport.closureList` and one under
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/`), independent of env_linter.
  This defect is pre-existing and already filed and owned by a different, separately-tracked
  record outside this task's scope (its own Non-Goals/Rollback sections commit zero `.lean`
  files). Measured: the prior unwidened mechanism's "16 of 18" dirty-root figure silently counted
  this root as dirty-but-contributing-zero only because its crash message happened not to match
  a `grep -c 'error: '` fallback pattern — a silent miscount `scripts/c16_roots_baseline.py`
  refuses to repeat. The corrected, re-measured figure is **231 findings across 15 of 17
  measurable roots**, not "231 across 16 of 18" — the total is unchanged, the denominator is
  more precise.

## Plan Deviations

- **Task 3.9** (commit list) altered: a fourth file, `scripts/c16-roots-unmeasurable.txt`, was
  committed alongside the three the plan named, required for the generator's own anti-silence
  guard to ever succeed (see Decisions above).
- That file was initially omitted from its phase's commit (never listed in any progress-file
  objective's `files_touched`, so the mechanized stage-list derivation never picked it up) and
  landed in a scoped follow-up commit one phase late, after first widening the task's declared
  `file_scope` in `specs/state.json` by one entry. Recorded in the Phase 3 progress file's
  `deviations` array and as an issue-log entry.
- Phase 5's own prose describing the C20 falsification seeds initially reproduced the literal
  `file.lean:NNN` citation shape inside `docs/development/MODULE_INVARIANTS.md`, which C20 itself
  then detected as a new, real citation in publication-facing scope (`docs/` is in C20's own
  scanned scope). Caught by re-running the gate before committing; fixed by rephrasing
  ("`Formula.lean`, line 5" instead of "`Formula.lean:5`"). No commit ever carried the broken
  phrasing.

## Verification

- Build: N/A (no `.lean` source edited).
- Tests: N/A (no test files edited).
- Files verified: Yes — all nine touched source/doc files plus four new data files confirmed
  present and tracked (`git ls-files`).
- `bash scripts/readme-lint.sh` and `bash scripts/readme-lint.sh FormalSystem BimodalTools`: PASS, exit 0.
- `bash scripts/check-module-invariants.sh --no-build`: ALL CHECKS PASSED, exit 0.
- `bash scripts/check-module-invariants.sh` (full mode): ALL CHECKS PASSED, exit 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: PASS, exit 0.
- `python3 scripts/c16_roots_baseline.py --log-dir <fresh-sweep-dir>` (compare mode): OK, exit 0.

### Consolidated falsification record (six seeded arms, each FAIL+nonzero observed together, then reverted to PASS+0)

1. **README stale date** — `FormalSystem/Automation/ProofMode/README.md`'s stamp edited to
   predate its directory's last commit. `bash scripts/readme-lint.sh FormalSystem BimodalTools` →
   `STALE DATE` printed, `RESULT: FAIL (1 new stale dates, 0 new missing dates)`, exit 1. Reverted
   → `RESULT: PASS`, exit 0.
2. **README missing date** — `FormalSystem/ForMathlib/Order/README.md`'s stamp line deleted.
   Same command → `MISSING DATE` printed, `RESULT: FAIL (0 new stale dates, 1 new missing
   dates)`, exit 1. Reverted → `RESULT: PASS`, exit 0.
3. **C20 residual** — a bare, nameless `FormalSystem/Syntax/Formula.lean` citation (line 5)
   appended to `scripts/check-evidence-probes.sh`. `bash scripts/check-module-invariants.sh
   --no-build` → `FAIL C20 residual ceiling: 1 (path, category) pair(s) exceed their pinned
   ceiling`, exit 1. Reverted → `PASS`, exit 0.
4. **C20 unverifiable-declaration** — a citation naming a non-existent declaration against the
   same target file, appended to `scripts/README.md`. Same command → `FAIL C20 residual ceiling:
   1 ...`, exit 1. Reverted → `PASS`, exit 0.
5. **C20 unverifiable-filename** — a citation naming a filename that resolves to no live file,
   appended to `scripts/README.md`. Same command → `FAIL C20 residual ceiling: 1 ...`, exit 1.
   Reverted → `PASS`, exit 0.
6. **C16-roots** — an undocumented `def` with a non-trailing underscore appended to
   `scripts/CheckInitImportsMain.lean` (a root other than the one any seed above touched, on the
   C25 precedent). After rebuilding that one root, full-mode `bash
   scripts/check-module-invariants.sh` (no `--no-build`) → `FAIL C16 env_linter batch over the
   other lakefile roots reports finding(s) above the pinned ceiling` (a NEW `defsWithUnderscore`
   row and an ABOVE `docBlame` row — the undocumented seed tripped both linters), exit 1. In the
   SAME run, `runLinter FormalSystem` (first half) stayed `PASS`, and a separately-run
   `--no-build` pass stayed exit 0 — the exact invisible-failure condition this half closes,
   since CI invokes `--no-build` and so never executes this half at all. Reverted and rebuilt →
   `PASS`, exit 0.

All three enforcement flags (`ENFORCE_README_DATES`, `ENFORCE_C20_RESIDUAL`,
`ENFORCE_C16_ROOTS`) default to 1 and were each separately confirmed to downgrade FAIL to
TODO/soft (with exit 0) when set to 0 against a live, above-baseline finding — a flag that does
nothing is a flag that lies.

## Impacts

- A new README stale/missing date, C20 residual/unverifiable-declaration/unverifiable-filename
  finding, or C16 env_linter finding on a non-`FormalSystem` root now fails the relevant local
  gate immediately, rather than drifting upward silently under an advisory-only PASS.
- The widened C16-roots scope is enforced only in the **local full-mode** invocation; CI invokes
  `--no-build` and so does not execute either C16 half. Extending CI coverage is explicitly out
  of this task's scope (a `ci.yml` change with a matching `report` line and `expected` bump).
- `BimodalToolsTest`'s build break is now visible on every full-mode run (an INFO line), rather
  than silently miscounted as a clean or zero-contributing root.

## Follow-ups

- None owned by this task. Two related, separately-tracked items this task's measurements touch
  but do not resolve: `BimodalToolsTest`'s "Ambiguous term closureList" build break, and
  extending CI (`ci.yml`) coverage to the widened C16-roots scope.

## References

- Plan: specs/938_enforceable_repo_health_baselines/plans/01_enforceable-health-baselines.md
- Report: specs/938_enforceable_repo_health_baselines/reports/01_enforceable-health-baselines.md
- Progress files: specs/938_enforceable_repo_health_baselines/progress/phase-{1..6}-progress.json

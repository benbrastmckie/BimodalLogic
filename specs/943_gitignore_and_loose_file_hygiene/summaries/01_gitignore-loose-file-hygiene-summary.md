# Implementation Summary: Task #943

- **Task**: 943 - Close three small gitignore and loose-file hygiene gaps at the repository root
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T20:04Z
- **Completed**: 2026-11-19T20:27Z
- **Effort**: 1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_gitignore-loose-file-hygiene.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed all three hygiene gaps named in the research/plan across exactly two files: `.gitignore`
(gaps A and B) and `ORGANISATION.md` (gap C). `Challenge.lean` itself was documented, not
relocated — the research correction established it as a deliberate, git-pinned Comparator
snapshot artifact, not abandoned cruft. Both phases closed `[COMPLETED]`.

## What Changed

- `.gitignore` — added `latex/build/` beneath the existing `latex/**/*.log`/`typst/**/*.log`
  pair, and an anchored `/.pid` beside `/.agent-logs` in the root-only runtime block. Exactly 2
  insertions, 0 deletions.
- `ORGANISATION.md` — added one row to the "Everything else" table documenting `Challenge.lean`
  as the committed, git-pinned statement set produced by the agent-system lean extension's
  `lean-challenge-snapshot.sh` Comparator snapshot step; notes it is not a Lake root, is not
  built, its `sorry` bodies are intentional (the module pins statement signatures, not proofs),
  and it should be left in place. Exactly 1 insertion, 0 deletions. `Challenge.lean` itself is
  untouched (`git diff HEAD -- Challenge.lean` empty throughout).

## Decisions

- Gap (A) implemented as a clarity/robustness addition, not a cruft-removal: the research report's
  correction holds — `latex/build/` byproducts were already ignored via `.gitignore` line 3's
  generic `build/` rule (`git check-ignore -v latex/build/BimodalReference.aux` ->
  `.gitignore:3:build/` both before and after the edit). The new local rule makes the intent
  explicit and resilient to line 3 ever being narrowed.
- Gap (C) resolved by documentation only, per the research's hard finding: `Challenge.lean` is a
  deliberate, mechanism-produced trust-boundary artifact (Comparator statement pinning), and
  relocating it to `Boneyard/` would have removed the location the next snapshot cycle writes to.
- `/.pid` placed beside `/.agent-logs` (not `*.tmp`) in the anchored root-only block, grouping it
  with the sibling runtime paths the finding named.
- `Challenge.lean`'s ORGANISATION.md row avoids any `agent-system/`- or `.claude/`-relative path
  (both dead or gitignored references in this repository), any task-numbered phrasing, and any
  record-versioning language, per the authoring constraints in the plan and the repository's
  deliverable rules.

## Plan Deviations

- **Task 1.7** (commit) / verification: `verify-touched.sh .gitignore` surfaced one NEW failure
  in `test-verify-deploy-gate-selection.sh` case(t), root-caused as pre-existing and unrelated to
  this task — the test's fixture setup depends on `agent-system/extensions/`, a directory absent
  from this entire repository. Recorded via `issue-record.sh`.
- **Task 2.5** (scoped touched-path check): `verify-touched.sh .gitignore ORGANISATION.md`
  additionally ran an OWED fallback battery (95 suites, free cost-class) for the unmapped
  `ORGANISATION.md` path, surfacing 11 further NEW failures. All 11 root-cause to the same
  structural gap (`agent-system/extensions/` absent from this repository) and none touch
  `.gitignore`/`ORGANISATION.md` content; the two suites that would catch a problem in the added
  row (`test-check-record-versioning.sh`, `test-check-task-references.sh`) both PASS. Recorded
  via `issue-record.sh`; not treated as a regression.
- Verification criterion "`.pid` listed as `!!` in `git status --porcelain --ignored`" could not
  be literally observed at close-of-phase because the stray `.pid` file itself no longer existed
  on disk by then (a transient runtime PID file, removed independently once its owning process
  exited). The rule's correctness was instead confirmed via `git check-ignore -v .pid` ->
  `.gitignore:110:/.pid` (pattern match, independent of the file's current existence).

## Verification

- Build: N/A (no Lean source touched)
- Tests: `bash scripts/check-module-invariants.sh` — exit 0, "ALL CHECKS PASSED", identical to
  the pre-change baseline (only diff: the expected commit-SHA stamp and an informational
  build-lock-wait line from sibling task 941's concurrent build). `bash scripts/readme-lint.sh`
  — exit 0, output byte-identical to the pre-change baseline ("RESULT: PASS", 62 pre-existing
  stale-date info findings, 0 broken refs).
- `bash .claude/scripts/verify-touched.sh .gitignore ORGANISATION.md` — ran per the dispatch's
  Batch Gate Deferral directive (Phase 2 declared `**Verification Tier**: full`); surfaced only
  pre-existing, unrelated failures as detailed in Plan Deviations above. The full gate set
  (`verify-deploy.sh`) remains deferred to the batch-level close per that directive.
- Files verified: Yes — `git diff --stat` across the whole task shows exactly two files changed
  (`.gitignore` +2/-0, `ORGANISATION.md` +1/-0); `git ls-files latex` returns zero; `git ls-files
  .pid` returns nothing; `git diff HEAD -- Challenge.lean` empty throughout.

## Impacts

- `latex/build/` byproducts and `.pid` are now explicitly and robustly ignored at the repository
  root; no tracked file became newly ignored.
- A future reader of `ORGANISATION.md` can now tell why `Challenge.lean` exists at the repository
  root, why its `sorry` bodies are expected, and that it must not be deleted or moved.

## Follow-ups

- None for this task's own scope. The 11 OWED-fallback test failures and the 1 scoped-suite
  failure recorded above are pre-existing, environmental (missing `agent-system/extensions/` in
  this repository) gaps unrelated to `.gitignore`/`ORGANISATION.md`; fixing them is a separate,
  out-of-scope concern.

## References

- `specs/943_gitignore_and_loose_file_hygiene/reports/01_gitignore-loose-file-hygiene.md`
- `specs/943_gitignore_and_loose_file_hygiene/plans/01_gitignore-loose-file-hygiene.md`
- `specs/reviews/review-2026-11-19.md`

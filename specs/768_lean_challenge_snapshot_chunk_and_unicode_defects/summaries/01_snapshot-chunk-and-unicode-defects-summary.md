# Implementation Summary: Task #768

- **Task**: 768 - Fix three independent defects in `lean-challenge-snapshot.sh`
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T02:39:50Z
- **Completed**: 2026-11-05T05:15:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_snapshot-chunk-and-unicode-defects.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All three defects in `lean-challenge-snapshot.sh` are repaired, across six serial phases, in the
source-store repository (`~/.config/nvim`): the already-landed Goals list-item anchor and
reserved-keyword denylist repair is committed; the four ASCII-only identifier sites now read one
shared, Unicode-aware pattern; the declaration-chunk boundary is widened to recognize `abbrev`
and an anonymous `instance` while a decoupled name-harvest/body-forcing policy keeps the
cross-validated identifier set and the sorry-forcing breadth exactly as before; the Goals
identifier harvest is narrowed to each bullet's own leading identifier run, closing the
over-reading defect structurally; and `--dry-run` gained an opt-in `--compile` step that converts
a silent assembly defect into a loud, fatal compile failure. The deploy tree is regenerated and
verified byte-identical to the source store.

## What Changed

All edits landed in the source-store repository (`/home/benjamin/.config/nvim`), per
`.claude/rules/source-store-deploy-boundary.md`; none were hand-edited under `.claude/**` in this
repository, which was instead regenerated via `deploy-headless.sh`.

- `agent-system/extensions/lean/scripts/lean-challenge-snapshot.sh` — one shared, Unicode-aware
  identifier pattern (`LEAN_IDENT_PATTERN`) replacing four independent ASCII-only literals; a
  widened, decoupled declaration-boundary policy (`LEAN_DECL_BOUNDARY_KW` /
  `LEAN_DECL_NAME_KW`) recognizing `abbrev` and an anonymous `instance` as chunk boundaries
  without widening what is cross-validated or forced to `sorry`; a leading-identifier-run rule
  in `extract_goal_names()` replacing the whole-line backtick-token scan; a new opt-in
  `--compile` flag with toolchain/Lake-project detection, a scratch-directory compile step via
  `lake env lean`, and a new fatal exit code (74); and a header documenting the accepted Goals
  surface and the full exit-code vocabulary.
- `agent-system/extensions/lean/scripts/tests/test-lean-challenge-snapshot.sh` — extended from 17
  to 29 passing cases: R9/R10 (Unicode identifier harvesting and the truncation-collision
  guard), R11/R12/R13 (the widened boundary and its decoupling), R14 (non-keyword trailing-prose
  tokens), and R15/R15-REAL/R16/R17 (the `--compile` step's stub and real-toolchain paths, skip
  path, and usage-rejection paths).
- `agent-system/extensions/lean/manifest.json` — registers every new fixture in
  `provides.scripts`, closing the gap that left the deployed suite's R8 case failing even after
  a clean redeploy.
- Ten fixtures under `agent-system/extensions/lean/scripts/tests/fixtures/challenge/` migrated
  from a mid-sentence Goals shape to the identifier-leading shape the narrowed rule requires
  (`plan_r1.md`, `plan_keyword_noise.md`, `plan_legacy.md`, `plan_list_item_goals.md`,
  `plan_mismatched.md`, `plan_mixed_case.md`, `plan_r9_unicode.md`, `plan_r10_truncation.md`,
  `plan_r11_abbrev_between.md`, `plan_r12_anon_instance.md`); five new fixtures created
  (`plan_r9_unicode.md`, `plan_r10_truncation.md`, `plan_r11_abbrev_between.md`,
  `plan_r12_anon_instance.md`, `plan_r14_trailing_prose.md`); one pre-existing untracked fixture
  committed (`plan_goals_preamble.md`).
- `agent-system/extensions/core/context/formats/plan-format.md` — one additive sentence in the
  `## Lean Challenge Statements` section making the Goals-bullet identifier-leading positional
  rule explicit (the sibling cross-repo record claiming this file was re-checked `not_started`
  at every decision point).
- The deployed `.claude/**` tree in this repository — regenerated via `deploy-headless.sh`
  (`RESULT=landed_verify_clean`), never hand-edited; verified byte-identical to the source store
  by direct `diff` and fixture-set comparison.

## Decisions

- The identifier pattern `[^\W\d][\w']*` is defined once as an exported shell variable (not a
  sibling Python module), read via `os.environ` inside each of the four independently
  `'PYEOF'`-quoted heredocs — no new deploy-manifest-registered file, no `argv` contract changes.
- The declaration-boundary alternation is deliberately decoupled into three roles (boundary,
  name-harvest, body-forcing) rather than widened as one undifferentiated regex, specifically to
  avoid newly requiring every `abbrev` to be a Goal or forcing an unusable `abbrev Bar := sorry`.
- The Goals-identifier narrowing discriminates by POSITION (a bullet's own leading identifier
  run) rather than by extending the keyword denylist or filtering the harvested set against the
  declared set — both alternatives were explicitly rejected as unsafe or tautological.
- `--compile` is opt-in (not default under `--dry-run`) and its failure is fatal (a distinct exit
  code, never advisory), compiling in a scratch directory outside `project_root` via
  `lake env lean` so the target project's own Lake environment resolves imports.
- A real Lean toolchain was found reachable on the implementing host, so the stub-only R15 case
  was extended with R15-REAL (both success and failure paths against the real compiler),
  guarded to skip automatically on a host without one.

## Plan Deviations

- **Phase 4** (task 4.4, fixture migration): ALTERED in scope. The plan named two fixtures
  needing migration to the identifier-leading Goals shape; re-extracting every fixture's Goals
  block (per the phase's own Scope Hypothesis instruction) found ten, not two. All ten were
  migrated; the suite stayed green throughout. See the Phase 4 progress file's `deviations`
  array.
- **Phase 5** (task 5.5, test case R15): ALTERED in scope. A real Lean toolchain was found
  reachable on this host, so R15-REAL (the real-toolchain success and failure paths) was added
  alongside the plan-named stub case, per the phase's own Scope Hypothesis contingency. See the
  Phase 5 progress file's `deviations` array.
- No other deviations. All other phases completed exactly as planned.

## Verification

- Build: N/A (shell script; no build step)
- Tests: Passed — source-store suite 29 passed / 0 failed / 0 skipped (up from the 17-case
  baseline); deployed suite (post-redeploy) 29 passed / 0 failed / 0 skipped.
- Files verified: Yes — `diff` confirms the deployed script and suite are byte-identical to the
  source store; the deployed and source-store `fixtures/challenge/` directories hold the
  identical fixture set.
- Scoped gate (Batch Gate Deferral): `run-all.sh --only
  test-lean-challenge-snapshot.sh,test-phase-heading-patterns.sh,test-plan-file-scope-harvest.sh,test-resume-scan-nonconformance.sh,test-check-task-references.sh,test-check-record-versioning.sh,test-index-entries-schema.sh`
  — 7 passed, 0 failed. The independent full `verify-deploy.sh` invocation was deferred to the
  once-per-batch stage per this dispatch's `## Batch Gate Deferral` directive.
- `check-task-references.sh` / `check-record-versioning.sh` run individually against every
  edited file: 0 unexempted task-reference occurrences on all; the one record-versioning
  advisory finding introduced by this work (a comment narrating removed code) was reworded to
  state current behavior directly.

## Impacts

- Every plan that previously had to route around these defects (hoisting supporting definitions
  as `abbrev`s ahead of the first theorem, renaming non-ASCII identifiers to ASCII, de-backticking
  non-goal prose in the Goals block) no longer needs those workarounds.
- The deployed `lean-challenge-snapshot.sh` now matches the source-store copy exactly, so a lean
  plan processed via the deployed `.claude/scripts/` copy gets the same R1-R17 behavior as the
  source-store copy, including the previously deployed-only-broken R8 case.
- `plan-format.md`'s `## Lean Challenge Statements` section now states the Goals-bullet
  positional rule explicitly, so a plan author writing a new lean/lean4 plan has the accepted
  surface documented at the point where Goals bullets are specified, not only in the script's
  own comments.

## Follow-ups

- None required by this record. The sibling cross-repo record (`lean4_plan_with_zero_lean_goals`,
  claiming this same script and `plan-format.md` for a different subject — the sanctioned shape
  of a lean4 plan with no theorem deliverable) remains `not_started` and unaffected by this work;
  it should re-check this record's landed state before it begins, per the coordination note this
  plan's Phase 4 recorded.
- The `lake-manifest.json` bootstrap write `lake env` performs on a never-built Lake project (an
  inherent Lake behavior, not introduced by this `--compile` step) is noted in the Phase 5
  handoff for awareness; it does not affect any real target project, which must already have a
  committed manifest to build at all.

## References

- Plan: `specs/768_lean_challenge_snapshot_chunk_and_unicode_defects/plans/01_snapshot-chunk-and-unicode-defects.md`
- Report: `specs/768_lean_challenge_snapshot_chunk_and_unicode_defects/reports/01_snapshot-chunk-and-unicode-defects.md`
- Progress files: `specs/768_lean_challenge_snapshot_chunk_and_unicode_defects/progress/phase-{1..6}-progress.json`
- Handoffs: `specs/768_lean_challenge_snapshot_chunk_and_unicode_defects/handoffs/phase-{1..6}-handoff-*.md`
- Source-store commits (in `/home/benjamin/.config/nvim`): `80d43b2e2` (Phase 1),
  `330a9309c` (Phase 2), `7626d37a9` (Phase 3), `8d3ab3283` (Phase 4), `a74eaf89f` (Phase 5),
  `94234b3a6` (Phase 6 touch-up)

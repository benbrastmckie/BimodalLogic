# Implementation Summary: Task #720

- **Task**: 720 - Promote FMP width refutations to evidence (re-scoped: CI repair of the untracked `WIRED_REPO` entries + citation re-point to the landed `Limits/` theorems)
- **Status**: [COMPLETED]
- **Started**: 2026-10-10T07:56:06Z
- **Completed**: 2026-10-10T08:06:16Z
- **Effort**: ~10 minutes wall-clock (plan estimate 2 hours)
- **Dependencies**: 706, 710 (archived as completed; their `Limits/` landings are at HEAD)
- **Artifacts**: plans/01_ci-repair-and-citation-repoint.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The evidence-probe gate `scripts/check-evidence-probes.sh` was red on every CI push because two
of its three `WIRED_REPO` entries pointed at files git does not track (archived under the
gitignored `specs/archive/`), and `check_probe` tested presence only. This implementation closes
the mechanism (a `git ls-files --error-unmatch` tracked-ness check that fails loudly and
distinctly), deletes the two entries whose content the `lake build`-guarded modules
`PlusSlicedCertificate/Limits/FiniteCarrier.lean` and `Limits/NoFiniteWidth.lean` fully subsume,
re-points `FMP/README.md` and `Limits/README.md` from the archived `Probe706.`/`Probe710.` names
to the landed library names, and records the archival-`mv` un-tracking rule in the source store.
No Lean source changed; `lake build` was run as the task's named finish line.

## What Changed

- `scripts/check-evidence-probes.sh` — `check_probe` gains a tracked-ness branch after the
  missing-file test (`FAIL (untracked: ...)`); header paragraph `TRACKED, NOT MERELY PRESENT.`;
  four-line footer clause for the untracked case; the 706/710 comment paragraph and the two
  `specs/archive/706_...`/`specs/archive/710_...` array lines removed, leaving the 476 entry as
  the sole `WIRED_REPO` entry (its paragraphs byte-for-byte unchanged).
- `FormalSystem/Metalogic/Decidability/FMP/README.md` — subsection "The finite-carrier route is
  refuted, not merely open" now cites
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FiniteCarrier.no_finite_carrier_sat`
  (corollary `not_finite_carrier_fmp`) and `...NoFiniteWidth.not_finite_width_fmp` (corollary
  `not_sliced_complete`), each with a relative link to its module; the "compiled outside the
  build graph; see `scripts/check-evidence-probes.sh`" parenthetical is deleted; the "Two limits"
  paragraph changed only in the four planned places (probes->proofs, probe->theorem, two names);
  `- [Limits README](../PlusSlicedCertificate/Limits/README.md)` added; `Last verified` bumped.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/README.md` — Provenance
  paragraph anchored to commits `1b7b8431f` (`NoFiniteCarrierModel.lean`) and `b1180dbf8`
  (`NoFiniteWidthModel.lean`); both namespaces (`...FiniteCarrier`, `...NoFiniteWidth`) named;
  "The probe is retained ... not superseded" replaced by "the library modules are the record and
  the sole guarded copy"; `Last verified` bumped.
- Source store `/home/benjamin/.config/nvim` (commit `7ffb39166`, branch `master`):
  `agent-system/extensions/core/context/patterns/task-abandon-mode.md` — one sentence after the
  archive `mv` block; `agent-system/extensions/core/skills/skill-todo/SKILL.md` — the same rule
  as a comment beside the literal `mv "$source_dir" "$target_dir"`.

## Decisions

- Deliverable B resolved by option (a) DELETE, as the plan directed: every declaration in both
  archived probes has a library twin, so a `WIRED_REPO` duplicate would only cost CI time.
- The tracked-ness check landed before the entries were deleted, so the two live untracked
  entries served as the negative test (exactly two `FAIL (untracked: ...)` lines, 26 PASS,
  `FAIL  2 of 28`) with no temporary edit.
- The missing-file branch stays first, so an absent file still reports `missing`, not
  `untracked`.
- `.github/workflows/ci.yml` untouched (no force-tracking under option (a)); nothing under
  `.claude/**` hand-edited.

## Plan Deviations

- **Phase 4, source-store commit** altered: the `git add` was the explicit two-file list, but
  `git diff --staged` was not reviewed before `git commit`, and three files another writer had
  already staged in that worktree (`specs/296_repo_hygiene_remove_stale_initluabackup_/
  .return-meta.json`, `issues.jsonl`, `metrics.jsonl`) rode along into `7ffb39166`. Not
  amended (history rewrite with a possibly-live writer is prohibited). Operator may want to
  split that commit; the two intended hunks are correct and self-contained.
- **Phase 5, repo-wide grep** altered: `NoFiniteCarrierModel|NoFiniteWidthModel` hits twice at
  `Limits/README.md:92-93`, which is the commit-anchored provenance wording Phase 3's own task
  text prescribes. No `Probe706`/`Probe710` namespace and no probe path citation remains.
- **Phase 4 locator**: the plan's "step 4c" `mv` in `skill-todo/SKILL.md` is numbered 7c in the
  current file; the comment went beside the real `mv` command. Work unchanged.

## Verification

- Build: Success — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  detached; guard exit 0 (Tier 1), `Build completed successfully (2839 jobs)` with 0 `error:`
  lines (Tier 2), `.olean` newer than source for `Limits/FiniteCarrier`, `Limits/NoFiniteWidth`
  and `PlusSlicedCertificate` (Tier 3). Cache hit: no `.lean` changed.
- Sorry count: 0
- Vacuous count: 1 — pre-existing false positive at baseline `50ff49288`
  (`FormalSystem/Examples/TemporalStructures.lean:495`, `intTimeHistory.domain t := trivial`, a
  genuine proof of a `True`-valued domain predicate); no `.lean` file touched by this task.
- Axiom count: 14 (baseline at `50ff49288`: 14; unchanged)
- Tests: N/A (no Lean change); repository gates:
  - `bash scripts/check-evidence-probes.sh` exit 0, `PASS  all 26 wired probe(s) compile`;
    tracked-ness loop over all 26 targets prints nothing.
  - `timeout 400 bash scripts/check-module-invariants.sh --no-build` ALL CHECKS PASSED.
  - `bash scripts/readme-lint.sh` PASS; all three new relative links from `FMP/README.md` resolve.
  - `bash .claude/scripts/verify-deploy.sh --only-gate 3,4` exit 0; full
    `verify-deploy.sh --skip-slow` PASS 14/14 (no staleness finding surfaced in this run).
  - `check-metalogic-cycles.sh` exit 1 and `typst-sync-check.sh` exit 1: pre-existing, unchanged
    from before this task, named in the plan's Non-Goals.
- Files verified: Yes
- Plan compliance spot-check: skipped — the plan's Goals name shell identifiers
  (`check_probe`, `WIRED`, `WIRED_REPO`, `mv`), not Lean declarations; `Lean Intent: false`.

## Impacts

- The `check-evidence-probes.sh` step of `.github/workflows/ci.yml` turns green on the next push
  (the two `FAIL (missing: ...)` lines are gone); the job as a whole stays red until the two
  unrelated pre-existing steps are repaired.
- Any future `WIRED_REPO` entry pointing into a task directory now fails loudly on the machine
  of whoever archives that task, instead of only on CI.
- `FMP/README.md` no longer claims the two refutations rest on files the build does not check.

## Follow-ups

- Operator: consider splitting source-store commit `7ffb39166` to separate the three swept-in
  `specs/296_...` files from the two intended hunks.
- Redeploy `.claude/` via `bash .claude/scripts/deploy-headless.sh` so the deployed
  `task-abandon-mode.md` and `skill-todo/SKILL.md` carry the new note (operator's call).
- `check-metalogic-cycles.sh` and `typst-sync-check.sh` remain red for reasons outside this task.

## References

- specs/720_promote_fmp_width_refutations_to_evidence/plans/01_ci-repair-and-citation-repoint.md
- specs/720_promote_fmp_width_refutations_to_evidence/reports/01_ci-repair-and-citation-repoint.md
- specs/720_promote_fmp_width_refutations_to_evidence/handoffs/ (phase-1 .. phase-4 handoffs)
- Commits (this repo): `42dd3772e`, `3109414d2`, `b0c02e555`, `dac2c63a3`; source store: `7ffb39166`

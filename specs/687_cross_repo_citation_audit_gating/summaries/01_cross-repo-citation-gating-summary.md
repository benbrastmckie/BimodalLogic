# Implementation Summary: Task #687

- **Task**: 687 - Cross repo citation audit gating
- **Status**: [COMPLETED]
- **Started**: 2026-09-27
- **Completed**: 2026-09-27
- **Effort**: ~3.5 hours
- **Dependencies**: 688 (completed)
- **Artifacts**: plans/01_cross-repo-citation-gating.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Closed the cited side of the cross-repository citation gap: re-verified every number the research
report asserted against today's tree, extended `scripts/lean-citation-seeds.txt` to cover the
consuming adequacy argument's §4.1 `ShiftSet.lean` proof-mapping cluster (10 new names, 53 → 63
seeded declarations), recorded that cluster's drift and a wrong-file citation in
`docs/reference/transcription-audit-surface.md`'s corrections table, made the three residue rows
the consuming audit does not reach (rows 3, 20, 24) copy-ready with explicit hand-off framing, and
recorded a deferred cross-repository manifest-consumer proposal. Nothing under
`~/Projects/ModelChecker` was written.

## What Changed

- `scripts/lean-citation-seeds.txt` — added a `##` group of 10 fully qualified names covering the
  consuming document's §4.1 `ShiftSet.lean` citations: `shRel_saturation`, `fibre_isRegular`,
  `frame_isRegular`, `forward_repr`, `total_eq_orbit`, `ShiftSet#sep` (field row), and the parent
  declarations `fibre`, `frame`, `ShiftTruth` the old citations actually land in today, plus
  `Truth.box_const` (added beyond the plan's expected nine — see Plan Deviations).
- `scripts/lean-citation-manifest.json` — regenerated; 63 seeded names resolved, byte-current.
- `docs/reference/transcription-audit-surface.md` — three new rows in "Corrections the consuming
  table owes" (7 wrong-declaration citations, 1 wrong-file citation, 2 correct-but-loose
  citations); a preamble sentence noting the extended seed coverage; hand-off framing for rows
  3/20/24 in "The three rows the consuming audit does not reach" (row 24's conditional preserved
  exactly); a new "deferred cross-repository proposal" subsection describing, but not
  implementing, a consuming-side manifest consumer.
- `scripts/check-module-invariants.sh` — comment-only addition to the C35 header noting the gate's
  coverage now includes the §4.1 cluster.
- `specs/687_cross_repo_citation_audit_gating/summaries/01_cross-repo-citation-gating-summary.md`
  — this file.
- **Not touched**: any file under `~/Projects/ModelChecker`; any Lean source under `FormalSystem/`;
  the residue table's 24 rows / 27 declarations (byte-identical before and after); any file outside
  `file_scope` (`docs/reference/README.md` and `docs/development/MODULE_INVARIANTS.md` were
  checked read-only and remain consistent, still stating "24 rows naming 27 declarations").

## Decisions

- Used measured values throughout rather than the research report's numbers, per the task's
  explicit "re-verify before editing" instruction — see Plan Deviations for where the measurement
  diverged.
- Added a tenth seed name (`Truth.box_const`) beyond the plan's nine-name expected set, because the
  corrections table cannot name a declaration that is not in the manifest, and Phase 1's
  measurement found `box_const`'s citation names the wrong file entirely.
- Left `docs/reference/README.md` and `docs/development/MODULE_INVARIANTS.md` unedited: both are
  outside `file_scope`, and the residue counts they cite did not change.
- Did not edit `*Last verified:* 2026-09-27` since it already read today's date.

## Plan Deviations

- **Task 2.2** (seed-list additions) altered: added `FormalSystem.Semantics.Truth.box_const`
  beyond the plan's nine-name expected candidate set. Reason: Phase 1's re-verification found the
  §4.1 Lemma-3/Corollary-3.1 row's second file:line citation does not merely land on the wrong line
  within the right file but names the wrong file entirely for `box_const` (its real location is
  `TruthTransport.lean:310`, not `WitnessFamily/Std.lean`); Phase 3's own verification clause
  requires every declaration named in a new corrections row to resolve in the manifest, so
  `box_const` had to be seeded to be nameable.
- **Research report's "six of nine wrong plus one further" figure superseded by measurement**: live
  re-verification against today's tree found **7 of 9** ShiftSet.lean citations land in a different
  declaration (not 6), plus the separate wrong-file citation for `box_const` — 8 wrong-declaration-
  class citations total, not 7. All nine ShiftSet.lean citations turned out to share a single
  uniform +9-line drift, traced via `git show ef4707035` to one docstring block that commit
  inserted above the whole cluster. This is a measurement correction, not a plan deviation in the
  scope sense — the plan explicitly anticipated this and instructed using the measured value.

## Verification

- Build: Success — `lake build` completed successfully (2741 jobs), no Lean source was touched.
- Tests: N/A (no test suite changes; the change is scripts/docs only)
- Full invariants gate: Success — `bash scripts/check-module-invariants.sh --no-build` exits 0,
  ALL CHECKS PASSED, including `PASS C5`, `PASS C12`, `PASS C13`, `PASS C20` (both tiers plus the
  declaration-span assertion), and `PASS C35` ("all 63 seeded declaration(s) resolve").
- `python3 scripts/export-lean-citations.py --check` exits 0 (manifest byte-current).
- `python3 scripts/export-lean-citations.py --stdout` resolves all 63 seeded names, no UNRESOLVED
  or AMBIGUOUS entry.
- `grep -nE '\.lean:[0-9]+' docs/reference/transcription-audit-surface.md` — zero matches, before
  and after every documentation edit.
- `git status --porcelain` (this repository) confines all non-`specs/**` changes to exactly the
  four declared `file_scope` files: `scripts/lean-citation-seeds.txt`,
  `scripts/lean-citation-manifest.json`, `scripts/check-module-invariants.sh`,
  `docs/reference/transcription-audit-surface.md`.
- `git -C ~/Projects/ModelChecker status --porcelain` — unchanged by this task throughout (its
  dirty entries at task start and finish are from other concurrently-running tasks in this
  session, not from this task).
- Files verified: Yes.

## Impacts

- A future rename or docstring sweep at any of the 63 seeded declarations — including the 10 newly
  covered §4.1 names — now fails C35 in this repository rather than rotting silently in the
  consuming repository's adequacy argument.
- The consuming repository's maintainers now have a mechanical, name-keyed list of every correction
  their §4.1 table and §4.2 residue audit owe, resolvable against the generated manifest without
  re-deriving locations by hand.
- The deferred cross-repository manifest-consumer proposal is a scoped, actionable starting point
  for a future task on the consuming side, rather than a silently dropped half of this task's
  description.

## Follow-ups

- Propose the four-citation (+38) and the new §4.1 (+9, plus the wrong-file `box_const` citation)
  corrections to the consuming repository's `ADEQUACY.md` — this task does not and must not edit
  that repository directly.
- Add rows for residue rows 3, 20 and 24 to the consuming repository's own §4.2 transcription
  audit, using the hand-off framing this task recorded.
- Consider implementing the deferred cross-repository manifest-consumer check on the consuming
  side (outside this repository's `file_scope`).

## References

- `specs/687_cross_repo_citation_audit_gating/reports/01_cross-repo-citation-audit-gating.md` —
  research report
- `specs/687_cross_repo_citation_audit_gating/plans/01_cross-repo-citation-gating.md` —
  implementation plan (all five phases `[COMPLETED]`)
- `docs/reference/transcription-audit-surface.md` — the edited page
- `scripts/lean-citation-seeds.txt`, `scripts/lean-citation-manifest.json` — the extended seed
  list and regenerated manifest
- `scripts/check-module-invariants.sh` — C35, the enforced build-free freshness gate

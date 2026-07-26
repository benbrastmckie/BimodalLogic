# Implementation Summary: Task #401

**Completed**: 2026-07-26
**Duration**: ~45 minutes

## Overview

Executed the authorized option (a) decision (`DECISION.md`): retired the sole all-rights-reserved
carve-out in this repository by bringing `Theories/Bimodal/typst/BimodalReference.typ` under
Apache-2.0. All five plan phases completed: both notice sites in the typst source, the README
carve-out paragraph, the regenerated tracked PDF, an explicit LaTeX header (Phase 4, included
rather than deferred), and a repo-wide consistency sweep.

## What Changed

- `Theories/Bimodal/typst/BimodalReference.typ` — Site 1 (`:10-11`, source comment) now reads
  "Copyright ... All rights reserved." / "Released under Apache 2.0 license as described in the
  file LICENSE.", matching the house `.lean` idiom. Site 2 (`:111`, rendered title-page prose) now
  reads "© 2026 Benjamin Brast-McKie. Licensed under the Apache License, Version 2.0." with a
  `#link` to the canonical Apache-2.0 URL — deliberately different wording from Site 1 since a
  standalone PDF reader cannot resolve "the file LICENSE".
- `README.md` — removed the carve-out paragraph from the License section; it now reads an
  unqualified Apache-2.0 statement.
- `Theories/Bimodal/BimodalReference.pdf` — regenerated via `typst compile` and promoted over the
  tracked path. Verified via `pdftotext` that the title page now shows the Apache-2.0 wording and
  no "All rights reserved." The only other visible diff is the title-page date
  (`#datetime.today()` stamps the current date), as anticipated by the plan.
- `Theories/Bimodal/latex/BimodalReference.tex` and `Theories/Bimodal/latex/BimodalDemo.tex` —
  added a two-line `%` comment header (mirroring Site 1) after each file's existing header block
  and before `\documentclass`. Phase 4 was included, not deferred: this closes the last silent
  case where a reader of the LaTeX file alone would see no license assertion.

## Decisions

- Phase 4 (LaTeX header) was executed rather than deferred, per the plan's own recommendation:
  zero-risk, closes the last silent license-assertion gap.
- Site 2 uses the linked form (`#link(...)[Apache License, Version 2.0]`) rather than the plain
  fallback, since `pdftotext` confirmed it renders as a single readable line on the title page —
  no wrapping issue observed.

## Plan Deviations

- None (implementation followed plan). One minor procedural note: `Theories/Bimodal/typst/build/`
  did not exist yet, so `mkdir -p build` was run before `typst compile` in Phase 3; this is
  consistent with the plan's expectation that `build/` is gitignored/untracked, not a deviation
  from the specified command.

## Verification

- Build: N/A (no Lean file modified by this task)
- `typst compile`: exit 0, no new errors (only pre-existing "unknown font family" warnings)
- `pdftotext` on tracked PDF: Apache-2.0 wording present, no "All rights reserved." on title page
- Tests: N/A
- Files verified: Yes — all five phases independently verified per plan criteria

## Notes

- The three `Tests/BimodalTest/` files (`TraceCertificateTest.lean`, `TraceExportTest.lean`,
  `TraceExporterE2ETest.lean`) named in the plan's non-goals as owned by a sibling task in this
  batch were observed, not touched: by the time Phase 5's sweep ran, the sibling task had already
  replaced their "Released under the project's standard license." notice with the standard Apache
  header and committed it. No double-edit occurred.
- Repo-wide sweep (excluding `docs/research/`, `specs/literature/`, and `specs/`) found no GPL-3.0
  or other non-Apache-2.0 assertion anywhere, and no contradiction between any two license
  assertions in the repository.
- Each phase was committed independently (`task 401 phase 1` through `phase 5`... phase 5 is
  verification-only, no commit needed for it beyond the plan-file checkbox updates), scoped only
  to this task's intended files. `git status` and `git show --stat` on each commit confirm no
  unintended files rode along.

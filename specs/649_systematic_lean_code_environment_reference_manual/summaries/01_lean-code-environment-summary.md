# Implementation Summary: One Lean-Code Environment for the Reference Manual

- **Task**: 649 - Systematic Lean code environment for the Bimodal Reference Manual
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T00:00:00Z
- **Completed**: 2026-09-29T00:00:00Z
- **Effort**: ~5 hours
- **Dependencies**: None outstanding (tasks 647 and 648 archived/completed before this task began)
- **Artifacts**: plans/01_lean-code-environment.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Promoted the file-local code-presentation rules that `typst/chapters/ax-lean-appendix.typ`
proved out into one book-wide `lean-code()` environment defined in `typst/template.typ`, with
two declared kinds (source excerpt with a module-qualified label bound inseparably to its code;
didactic example, no label), migrated every one of the manual's 50 code blocks across six
chapter files to it, added a mechanical Check 4 to `scripts/typst-sync-check.sh`, and documented
the environment in `typst/README.md` and `typst/STYLE.md`. Both `BimodalReference.typ` and
`FormalFoundations.typ` compile at zero errors; `FormalFoundations.typ` is byte-identical to its
pre-task state.

## What Changed

- `typst/template.typ`: new `lean-code(source:, breakable:, body)` environment, its five
  geometry constants (`lean-code-size` 8pt, `lean-code-font` "DejaVu Sans Mono",
  `lean-code-column-budget` 63, `lean-code-space` 11pt, `lean-code-indent` 1em), the
  `lean-code-label-raw` internal helper, `leansrc` rewired as a thin wrapper (signature
  unchanged), and `leanref` adopted (renders in the environment's font).
- `typst/chapters/ax-lean-appendix.typ`: all 44 code blocks (31 labeled, 13 didactic) migrated;
  its three file-local code-presentation rules deleted; 13 over-budget lines re-broken at
  whitespace.
- `typst/chapters/p2-decidability-practice.typ`, `p2-frame-classes.typ`,
  `p4-dual-verification.typ`, `p4-dataset-pipeline.typ`, `ax-machine-appendix.typ`: their six
  remaining blocks (including the JSON and Python listings) migrated the same way; five
  over-budget lines re-broken.
- `scripts/typst-sync-check.sh`: new Check 4 (bare-fence scan, column-budget scan,
  declaration-resolution scan over `typst/chapters/`), wired into the full run and summary line;
  a pre-existing triple-backtick comment in `template.typ` that tripped Check 1 was corrected in
  the same pass.
- `typst/README.md`: new "Code Environment" section; corrected the Scripts section's check count
  (was stuck at "2 checks", already stale before this task, now accurate at four).
- `typst/STYLE.md`: `#leanref`'s stated purpose recorded in the existing Lean-citations table.

## Decisions

- Explicit font `"DejaVu Sans Mono"` over the raw element's implicit default, whose per-glyph
  width was measured uneven across the manual's Lean unicode operators; confirmed by a rendered
  glyph check to cover every non-ASCII symbol used in a code block.
- Column budget 63, derived by rendering (not estimating) the narrowest real case: a block
  nested inside `#example`/`#definition` combined with the environment's own left inset.
- Uniform black-only rendering (`theme: none`) for every language, resolving the JSON/Python
  auto-highlighted vs. Lean-black inconsistency the research found, in favor of the template's
  stated austere aesthetic.
- Left indent (1em), not a left rule, for separation -- a rule was found to visually compete
  with `thmbox`'s own colored left bar on the theorem-family environments.
- A single outer unbreakable block (not the prototype's separate sticky-label-plus-unbreakable
  pairing) for atomicity, simpler and equally effective.
- `#leanref` adopted narrowly (matches `lean-code()`'s font for visual consistency); no existing
  inline backtick span converted.
- Check 4 added to the git-tracked `scripts/typst-sync-check.sh`, not the deployed, gitignored
  element lint under `.claude/`.

## Plan Deviations

- Phase 4 and Phase 5 were executed as one mechanical pass (a single script converting every
  fence pair in `ax-lean-appendix.typ`, both labeled and unlabeled, in one edit) rather than as
  two separate migration passes. Phase 5's own verification steps were still run afterward, as
  confirmation rather than as new migration work. No scope was skipped; see the plan's Phase 5
  section for the full account.

## Impacts

- Every Lean, JSON, and Python code block in the manual now renders identically: 8pt DejaVu Sans
  Mono, black, left-indented, unbreakable, with no wrapped line.
- A future chapter author gets the same presentation automatically via
  `#import "../template.typ": *`, with no file-local rules to author or maintain.
- `scripts/typst-sync-check.sh` now catches a bare fenced block, an over-budget line, or an
  unresolvable source-excerpt declaration mechanically, before it reaches a reviewer.

## Follow-ups

- An unrelated, pre-existing `Check 2` (`formalsystem-line-count`) drift was observed during
  Phase 7-9 and reported to the orchestrating session: it tracks a concurrent sibling task's
  ongoing commits to `FormalSystem/Metalogic/Decidability/` in this shared working tree, not
  anything this task touched. No action needed from this task; whoever finalizes that Lean work
  should regenerate `typst/generated/status.typ` before their own postflight.

## References

- `specs/649_systematic_lean_code_environment_reference_manual/plans/01_lean-code-environment.md`
  (all nine phases' measured results and render evidence)
- `typst/template.typ`, `typst/chapters/ax-lean-appendix.typ`,
  `typst/chapters/p2-decidability-practice.typ`, `typst/chapters/p2-frame-classes.typ`,
  `typst/chapters/p4-dual-verification.typ`, `typst/chapters/p4-dataset-pipeline.typ`,
  `typst/chapters/ax-machine-appendix.typ`, `scripts/typst-sync-check.sh`,
  `typst/README.md`, `typst/STYLE.md`

# Implementation Summary: Task #691

- **Task**: 691 - Resolve c23 naming exemptions
- **Status**: [COMPLETED]
- **Started**: 2026-09-28
- **Completed**: 2026-09-28
- **Effort**: ~2 hours
- **Dependencies**: None (tasks 685 and 693 had both already landed)
- **Artifacts**: plans/01_c23-naming-exemptions.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

C23 was the sole red gate group in `scripts/check-module-invariants.sh`, failing on two
sub-assertions: 2 `Uppercase_x` names (`NM_nonneg`) and 11 outer-shadows-inner bare-declaration
pairs. Both were deliberate mirrored-API/sub-namespacing decisions rather than naming defects, so
the fix is a recorded, narrow exemption inside the scanner — no `.lean` source file was touched.
`bash scripts/check-module-invariants.sh` now exits 0 with `ALL CHECKS PASSED`.

## What Changed

- `scripts/check-module-invariants.sh`:
  - Lifted the shadow-pair print truncation (`shadow[:10]`) to also emit an
    `... and {N} more` tail, matching the existing C26/dupNamespace idiom, so the eleventh pair
    is no longer silently hidden from the printed output (the reported count was already correct;
    only the print was truncated).
  - Added a new `SHADOW_PAIR_ALLOW` exemption set keyed on the exact
    `(base, outer_ns, inner_ns)` triple, populated with the 11 measured pairs in 3 reasoned
    groups (`decidableValidZTime`, `cohWindowLo`/`cohWindowHi`, `mem_verts`), applied in the pair
    loop alongside the existing `FROZEN_PREFIX` path check. Unlike the bare-name `SHADOW_ALLOW`
    set, this key exempts only the measured pairs — an unmeasured future collision on the same
    base name from a different namespace is still reported (proven in Phase 2 via a throwaway
    scratch-scanner narrowness check, reverted afterward).
  - Added `NM_nonneg` to `UPPER_ALLOW` and restructured its preceding comment into two named
    classes: (a) the existing no-such-prefix class, and (b) a new live-prefix,
    unwritable-dot-form class covering `NM_nonneg` — with both obstacles recorded (structure
    fields cannot contain dots; `S.NM.nonneg` would resolve against `Int`, which has no
    `.nonneg`), plus a note on why the three automatic exemption mechanisms miss this case. The
    `Uppercase_x` `PASS` message's class list was updated to match (`tense-operator,
    no-such-prefix, live-prefix and name-capture`).
- `specs/691_resolve_c23_naming_exemptions/plans/01_c23-naming-exemptions.md` — all four phases
  checked off with completion annotations.

## Decisions

- Followed the plan's pre-made decision: exemption key is the exact measured
  `(base, outer_ns, inner_ns)` triple, not a bare base name — so a genuinely new collision on any
  of the four exempted base names is still caught. No new design decisions were required during
  implementation; the plan's Decisions section fully determined the mechanism.

## Plan Deviations

- None (implementation followed plan). The measured inventory (11 shadow triples across 4 base
  names: `decidableValidZTime` x1, `cohWindowLo` x3, `cohWindowHi` x3, `mem_verts` x4; 26
  `NM_nonneg` occurrences across 5 files) matched the plan's Scope Hypotheses exactly, so no
  entry-list or figure adjustment was needed.

## Verification

- Build: Success (`bash scripts/check-module-invariants.sh` full run, not `--no-build`, exits 0)
- Tests: N/A (script-only change; no test suite covers this scanner directly)
- Files verified: Yes — `bash scripts/check-module-invariants.sh` prints `ALL CHECKS PASSED`,
  all three C23 sub-assertions read `PASS`, and diffing the Phase 1 `--no-build` baseline against
  the Phase 4 full-build run shows the only meaningful flips are the two C23 sub-assertions
  (red to green); every other delta is a group that reads `INFO ... skipped (--no-build)` in the
  baseline and `PASS` in the full run, which is the expected effect of actually running the build,
  not a regression or an unrelated fix.

## Impacts

- `scripts/check-module-invariants.sh` now exits 0 cleanly; C23 no longer needs to be treated as
  a known-red gate group in any future task or CI run.
- The shadow-pair print cap now reports every truncated row via an explicit `... and N more` tail
  tree-wide, not just for the pairs this task exempted — future FAIL output for a genuinely new
  shadow collision will also be complete rather than silently truncated at 10 rows.

## Follow-ups

- None. `scripts/typst-sync-check.sh` / `typst/generated/status.typ` remain red in the working
  tree on an unrelated stale count — explicitly out of scope per the plan's Non-Goals, and left
  untouched and unstaged by this task's commit.

## References

- Plan: `specs/691_resolve_c23_naming_exemptions/plans/01_c23-naming-exemptions.md`
- Research report: `specs/691_resolve_c23_naming_exemptions/reports/01_c23-naming-exemptions.md`

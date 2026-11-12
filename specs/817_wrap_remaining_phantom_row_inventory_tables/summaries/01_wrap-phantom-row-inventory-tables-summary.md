# Implementation Summary: Task #817

- **Task**: 817 - Wrap the remaining count-carrying inventory tables under FormalSystem/ whose blockers are phantom or missing rows
- **Status**: [COMPLETED]
- **Started**: 2026-11-12
- **Completed**: 2026-11-12
- **Effort**: ~2 hours
- **Dependencies**: None (parent task completed; sibling task owns a disjoint README set)
- **Artifacts**: plans/01_wrap-phantom-row-inventory-tables.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Six READMEs under `FormalSystem/` carrying seven count-bearing inventory tables, previously
invisible to the `INV` check because each had a row-set mismatch (phantom rows naming archived
files, missing rows for live files, or mis-keyed rows), are now wrapped in `<!-- BEGIN
GENERATED: inventory ... --> / <!-- END GENERATED -->` markers and brought under the gate. Every
row-set mismatch was resolved by hand before wrapping, so no hand-written description was
silently dropped. Coverage was demonstrated, not assumed, via a per-block corrupt/restore cycle.

## What Changed

- `FormalSystem/Metalogic/BXCanonical/Chronicle/README.md` — dropped the phantom
  `HenkinDiscreteChain.lean` row (archived, no live successor); added 8 rows for previously
  un-rowed live files, each description drawn from that file's own module docstring; wrapped
  `rows=loose cols=lines`; regenerated to 14 rows matching the 14 live files.
- `FormalSystem/Metalogic/BXCanonical/Quasimodel/README.md` — dropped the phantom
  `EnrichedClosure.lean` row (obsolete; `SubformulaClosure.lean`'s existing description already
  covers the territory); wrapped `rows=loose cols=lines`; regenerated to 5 rows.
- `FormalSystem/Metalogic/Core/RestrictedMCS/README.md` — dropped the phantom `Deferral.lean`
  row (deferral machinery retired wholesale to `Boneyard/`, not merged into `Basic.lean`);
  wrapped `rows=loose cols=lines`; regenerated to 1 row.
- `FormalSystem/Metalogic/Expressiveness/Separation/README.md` — dropped 10 phantom `.lean` rows
  and 2 phantom subdirectory rows (`DedekindZ/`, `Hierarchy/`), all archived under
  `Boneyard/Kamp/KampWeakCanonical/Separation/`; deliberately rewrote `Defs.lean`'s description
  (the live module is the integer-time `IntStructure`/`IntTruth` approach, not the archived
  `N`-types approach the old text described); added rows for `KampTranslation.lean` and
  `SemanticBridge.lean`; wrapped `rows=both cols=lines`; regenerated to exactly 3 rows.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — two blocks:
  - Upper `## Modules` table: wrapped `rows=loose cols=lines` with no row-set change (7 rows,
    matching the 7 live loose files); the `Compression/` 2-column section and the lower
    `### Sharing/` table were confirmed byte-identical before/after.
  - Lower `### Sharing/` table: re-keyed all 9 existing rows from `Sharing/`-prefixed to bare
    filenames (the generator's `row_key()` performs no path normalization, so a prefixed key
    would have orphaned every description); resynced all 9 descriptions' text from
    `Sharing/README.md`'s own already-wrapped, already-current block (the old text was stale in
    content, not only counts); added 3 rows (`Skeleton.lean`, `Stability.lean`, `Window.lean`);
    wrapped `rows=loose cols=lines`; regenerated to 12 rows, every cell byte-identical to
    `Sharing/README.md`'s block.
- `FormalSystem/Metalogic/BXCanonical/README.md` — no row-set change (12 rows: 8 loose + 3
  subdirectory + 1 pinned `../BXCanonical.lean`); wrapped `rows=both cols=lines`; the pinned row
  survived regeneration with its description and count (43) unchanged — the specific path the
  earlier sweep never exercised.

Each of the six files was committed independently, one commit per phase, staged by explicit file
list (plus this task's own `specs/817.../` artifacts).

## Decisions

- All phantom rows were judged obsolete and dropped with no re-homing: each traces to a file
  moved into `Boneyard/` (archived, not deleted), and in no case does a live sibling continue the
  archived work.
- `Separation/Defs.lean`'s description was deliberately rewritten rather than carried forward,
  because the generator matches on the key and the key survived an underlying approach swap
  (archived `N`-types approach -> live integer-time approach) that the old prose still described.
- The duplication between `WitnessFamily/README.md`'s resynced lower table and
  `Sharing/README.md`'s own block is an accepted trade-off (per the task's research): `INV`
  checks each generated block against its own directory's live files only, never cross-block
  consistency, so nothing keeps the two copies in sync automatically going forward. This mirrors
  the existing `Compression/` top-level-summary convention already accepted elsewhere in the
  tree.
- Phase 6's task list expected the BXCanonical table's subdirectory rows' `—` Lines cells to be
  replaced by real numbers under `cols=lines`. This expectation was wrong, not the
  implementation: per `scripts/check-module-invariants.sh`'s `inventory_rows()`, a subdirectory
  row's Lines-cell substitution is gated on `cols=files-lines`, never on `rows=both`/`cols=lines`
  — the latter always emits a literal `—` for a subdirectory row. Verified directly against the
  writer's actual output and the generator source; no correction was made because none was
  needed.

## Plan Deviations

- **Phase 6, task 5** (subdirectory-row Lines substitution): altered from "expect real numbers"
  to "verified and documented that `—` is the correct, designed output under `cols=lines`" — see
  Decisions above. No functional change to the implementation; the plan's expectation was simply
  inaccurate.

## Verification

- Build: Success — `bash scripts/check-module-invariants.sh` (full run, including `lake build`
  and `lake build BimodalTest`) reports `ALL CHECKS PASSED` with zero `FAIL` lines.
- Tests: N/A (no `.lean` file modified or staged by any phase; `BimodalTest` build pass is
  covered by the full gate run above).
- Files verified: Yes — every phase's key-sorted before/after diff was empty except the three
  deliberate description changes in Phase 3 (`Defs.lean` rewrite, 2 new rows) and the twelve
  deliberate resyncs in Phase 5.

### Per-block corrupt/restore coverage demonstration (Phase 7)

| # | Block | Cell corrupted | `FAIL INV` named exactly this file | Restored, empty diff |
|---|-------|-----------------|----|----|
| 1 | Chronicle | `ChronicleConstruction.lean` Lines 1,611 -> 9999 | Yes | Yes |
| 2 | Quasimodel | `Construction.lean` Lines 846 -> 9999 | Yes | Yes |
| 3 | RestrictedMCS | `Basic.lean` Lines 368 -> 9999 | Yes | Yes |
| 4 | Separation | `Defs.lean` Lines 582 -> 9999 | Yes | Yes |
| 5 | WitnessFamily upper | `Closure.lean` Lines 131 -> 9999 | Yes | Yes |
| 6 | WitnessFamily lower (Sharing) | `Agreement.lean` Lines 460 -> 9999 | Yes (and the upper block, left uncorrupted in this cycle, was not independently flagged, confirming the two blocks in the same file are checked independently) | Yes |
| 7 | BXCanonical (pinned row) | `../BXCanonical.lean` Lines 43 -> 9999 | Yes | Yes |

Each cycle: corrupted via a targeted `sed` substitution on the single numeric cell, confirmed
`bash scripts/check-module-invariants.sh --no-build` reports `FAIL INV` naming exactly the
expected README, restored via `bash scripts/check-module-invariants.sh --emit-inventory` (never
a pathspec checkout), and confirmed `git diff`/`git status --porcelain` for that file was empty
afterward.

`bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 (no registered block
would change a byte) after all seven cycles.

**Note on one false start**: the first corruption attempt on Chronicle used an overly clever
`sed` one-liner that accidentally truncated the file to its first two lines instead of touching
only the target cell. This was caught immediately (`git diff` showed the whole body deleted,
not a one-line change) and recovered losslessly via `git show HEAD:<path> > <path>` (the file's
own just-committed, known-good state) — not a pathspec checkout/restore, which the destructive-
git guard and the shared-worktree discipline both forbid on a dirty tree. All six subsequent
corruptions used plain line-targeted `sed -i 'N s/old/new/'` substitutions with no further
incident.

## Impacts

- All seven inventory blocks are now self-maintaining: a future edit to any of the 2 + 5 + 1 +
  3 + 7 + 12 + 12 live files they cover will be caught by `INV` if the table drifts, rather than
  silently going stale as it did before this task (measured at planning time: these six READMEs
  were among roughly 33 unwrapped `Lines`-bearing inventory tables under `FormalSystem/`, most
  of them stale).
- `WitnessFamily/README.md`'s lower table now duplicates `Sharing/README.md`'s content exactly;
  this is an accepted, documented trade-off (see Decisions), not a defect — but a future
  description change in `Sharing/README.md` will not automatically propagate to
  `WitnessFamily/README.md`'s copy, and vice versa.

## Follow-ups (untouched, still-unwrapped/stale inventory tables under `FormalSystem/`)

Reported per this task's NON-GOALS, without fixing any of them:

- **Reserved for the sibling column-set-mismatch task**: `FormalSystem/Metalogic/Expressiveness/
  Kamp/README.md` and `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md`
  remain unwrapped at the time of this writing (the sibling task's other two named READMEs,
  `Expressiveness/README.md` and `WeakCanonical/README.md`, were observed already wrapped —
  that sibling task's own concurrent progress, not this task's work).
- **Two findings beyond the dispatch's framing** (neither reserved by any task found in this
  survey):
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` carries a
    4-column `Module | Lines | Decls | Role` table — a column-set mismatch like the four reserved
    READMEs, but not among the four named in this task's dispatch or its sibling's scope.
  - `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` carries a clean, standard
    3-column `File | Lines | Description` table whose 13 rows match the 13 live files in that
    directory exactly (verified: empty diff between the table's keys and `ls *.lean`). It has no
    row-set or column-set blocker at all — it is simply unwrapped, and was never in scope for
    either this task or its sibling.
- **`Compression/` 2-column tables** (`Module | Contents`, no `Lines` column at all, explicitly
  out of this task's scope per its NON-GOALS): `FormalSystem/Metalogic/Decidability/
  WitnessFamily/Compression/README.md` (7 rows, 7 live files) and `FormalSystem/Metalogic/
  Decidability/PlusWitnessFamily/Compression/README.md` (unwrapped; row count not independently
  re-verified in this survey, out of scope).
- No currently-wrapped block anywhere under `FormalSystem/` is stale: the full gate run in Phase
  7 reported `ALL CHECKS PASSED` with zero `FAIL` lines across the whole tree.
- `.githooks/pre-commit`'s count-freshness gate never fired during this task, because no phase
  staged a `.lean` path (verified: it exits 0 unless a `.lean` path is staged). Consequently
  `typst/generated/status.typ` is untouched and uncoupled to this work (verified: no diff across
  this task's 6 phase commits; `scripts/typst-sync-check.sh` contains no inventory-block logic).

## References

- `specs/817_wrap_remaining_phantom_row_inventory_tables/reports/01_wrap-remaining-phantom-row-tables.md`
- `specs/817_wrap_remaining_phantom_row_inventory_tables/plans/01_wrap-phantom-row-inventory-tables.md`
- `scripts/check-module-invariants.sh` (the `INV` gate and `--emit-inventory` writer)

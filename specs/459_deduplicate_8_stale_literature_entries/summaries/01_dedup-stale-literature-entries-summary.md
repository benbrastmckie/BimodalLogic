# Implementation Summary: Task #459

- **Task**: 459 - Deduplicate 8 stale placeholder entries in the global literature index
- **Status**: [COMPLETED]
- **Started**: 2026-08-18T21:19:47Z
- **Completed**: 2026-08-18T21:38:00Z
- **Effort**: ~20 minutes
- **Dependencies**: 458 (satisfied; its mutations did not touch the 8-pair cluster)
- **Artifacts**: plans/01_dedup-stale-literature-entries.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Deleted the 8 stale, provenance-marked placeholder duplicate records from
`~/Projects/Literature/index.json`, keeping the fully-populated record in each pair. The deletion
used a guarded, assertion-first script that selects strictly on
`(id in the 8-id list) AND (provenance == "migrated from ingest schema
(doc_id/source_path/chunks_dir)")` — never on array position or `token_count`. A negative check
(marker stripped on a throwaway copy) proved the script's refusal path is live, not merely coded.
All field-level verification passed: the 8 surviving entries are byte-identical to their
pre-deletion canonical form, and the 3 `doc_id`-only entries plus 2 unpaired populated entries
remain untouched.

## What Changed

- `~/Projects/Literature/index.json` — 8 stale placeholder entries removed (369 -> 361 entries).
  No other content changed (isolated via diff against the Phase 1 backup: 206 removed lines, 0
  added lines, 2 contiguous hunks).
- `~/Projects/Literature/.literature.db` — rebuilt via `literature-build-index.sh --global`
  (ephemeral, disk-rebuildable artifact; not a source-of-truth mutation).
- No files changed inside the BimodalLogic repository outside `specs/459_deduplicate_8_stale_literature_entries/**`.

## Decisions

- **Distinct-id-count gate corrected from 361 to 358.** Live re-derivation in Phase 1 found the
  plan/report's parenthetical "361 distinct ids" to be an arithmetic slip (it applied
  `369 total - 8` instead of `366 id-carrying entries - 8`). The plan explicitly instructs gating
  on Phase 1's live re-derived value rather than the plan's literal in this situation ("never
  against this plan's literals" — Phase 4 Scope Hypothesis), so Phase 4 asserted equality against
  358, which held both pre- and post-deletion.
- **`git diff -- index.json` isolation required a different method than a raw git diff.** The
  Literature repo's `index.json` already carried an unrelated pre-existing dirty-tree modification
  (709 insertions / 435 deletions across 172 hunks against HEAD, from today's unrelated ingest
  activity). Isolating this task's own change required diffing the Phase 1 backup (taken after the
  pre-existing changes, before the dedup) against the post-deletion file, rather than `git diff`
  against HEAD.

## Plan Deviations

- None (implementation followed plan). The distinct-id-count number used (358, not the plan's
  literal 361) is not a deviation — it is exactly what the plan's own Phase 1/Phase 4 language
  instructs when live re-derivation diverges from the plan/report's literal on a non-set-membership
  number.

## Verification

- Build: N/A (data file, no build step)
- Tests: N/A (no test suite for this data file); manual field-level and byte-identity verification passed
- Files verified: Yes

**Final numbers**:

| Metric | Pre-deletion | Post-deletion |
|---|---|---|
| Total `entries` | 369 | 361 |
| Entries carrying `id` key | 366 | 358 |
| Distinct `id` count | 358 | 358 (unchanged) |
| Duplicated ids | 8 | 0 |
| `chunks_fts` row count | 17,736 (report baseline) | 17,736 (unchanged) |

- Round-trip serialization fidelity: byte-identical (proven before any mutation).
- Duplicated-id set: matched the report's 8 named ids exactly (set equality, both directions) —
  not a stop condition.
- Deletion script refusal path: demonstrated live (negative check on a throwaway copy with one
  marker stripped — exit 1, zero bytes written).
- Deletion selected exactly 8 rows (idx 344-349, 356-357 in the pre-deletion array), one per
  target id, each carrying the provenance marker.
- All 8 survivors byte-identical (canonical JSON, `sort_keys=True`) to their Phase 1 pre-images: 8/8.
- 3 `doc_id`-only entries (Jónsson-Tarski I/II, Goldblatt) and 2 unpaired populated entries
  (`pym_ohearn_yang_2004_...`, `ishtiaq_ohearn_2001_...`) confirmed present and unmodified.
- `literature-build-index.sh --global`: exit 0.
- `specs/literature-index.json` in this repo: confirmed untouched (no task-459 commit references
  it; working-tree diff vs HEAD unchanged from its pre-existing 41-insertion state).

## Impacts

- The global literature index no longer contains duplicate metadata records for the 8 affected
  ids, removing a source of confusion for future literature discovery/search over `index.json`.
- No downstream consumer is affected: `literature-build-index.sh --global` never reads
  `index.json` (confirmed by the research report and by this task's own FTS row-count check), and
  the repo's `specs/literature-index.json` sub-index contains none of the 8 ids.

## Follow-ups

- `~/Projects/Literature`'s working tree retains a pre-existing, unrelated dirty state (today's
  ingest activity) that was deliberately left uncommitted and unstashed per the plan's Non-Goals.
  No action needed from this task; flagged here only for visibility.
- None otherwise.

## References

- Plan: `specs/459_deduplicate_8_stale_literature_entries/plans/01_dedup-stale-literature-entries.md`
- Research report: `specs/459_deduplicate_8_stale_literature_entries/reports/01_dedup-stale-literature-entries.md`
- Progress files: `specs/459_deduplicate_8_stale_literature_entries/progress/phase-{1..5}-progress.json`
- Handoff: `specs/459_deduplicate_8_stale_literature_entries/handoffs/phase-1-handoff-20260818T212300Z.md`
- Backup: `~/Projects/Literature/index.json.bak-20260818-142007-pre-dedup`
- Deletion script (scratch, outside any repo tree): `dedup_delete.py` in this session's scratchpad directory

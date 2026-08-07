# Implementation Summary: Task #435

- **Task**: 435 - curate_termination_literature_subindex
- **Status**: [COMPLETED]
- **Started**: 2026-08-07T15:55:00Z
- **Completed**: 2026-08-07T18:05:00Z
- **Effort**: ~2 hours
- **Dependencies**: None
- **Artifacts**: plans/01_curate-termination-subindex.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Registered 7 termination-measure-relevant documents from the global Literature corpus into the
per-repo sub-index (`specs/literature-index.json`), each carrying a design-specific `relevance`
annotation stating which termination-ordering pattern it supplies (mosaic bound, closure-set
potential, prefix-length bound, or interval/density guard) and how it bears on the `MintPaysForTime`
termination-measure blocker. Ran a confirmatory online discovery pass (null result, well
documented) and verified the result against discriminating criteria — which caught and fixed a
real defect along the way.

## What Changed

- `specs/literature-index.json` — appended 7 new entries (`caleiro_2013`,
  `blackburn_2002_ch06_sec04-05`, `massacci_2000_single_step_tableaux_for_modal_logics`,
  `gerth_1995_onthefly_ltl`, `baier_katoen_2008_part04`, `vardi_wolper_1986_automata_verification`,
  `vardi_1996_automata_ltl`), each with both `relevance` (rendered by `literature-briefing.sh`)
  and `reason` (matching the file's existing provenance convention). Also merged a `relevance`
  field into the pre-existing `venema_2001_sec04` entry (see Decisions/Plan Deviations) rather
  than duplicating it. Bumped `updated` timestamp. Entry count: 33 -> 40.
- `specs/435_curate_termination_literature_subindex/plans/01_curate-termination-subindex.md` —
  all 6 phases checked off and marked `[COMPLETED]`, with inline evidence/decision records for
  the `baier_katoen_2008` part selection (Phase 2), the caleiro/Blackburn granularity decisions
  (Phase 3), the Phase 5 online-discovery null result, and the Phase 4/6 duplicate-doc_id
  correction.
- `specs/435_curate_termination_literature_subindex/progress/phase-{1..6}-progress.json` —
  per-phase objective tracking, created new.

## Decisions

- **Registration granularity**: registered the `caleiro_2013` parent (not its 7 `secNN`
  children — the parent is `verified_conversion` and already the whole focused paper) and
  exactly one Blackburn Ch.6 section, `blackburn_2002_ch06_sec04-05` ("Quasi-models, Mosaics,
  and Tiling") — accepting its UNVERIFIED stamp deliberately because it is the precise on-topic
  match, versus the 35-chunk whole book (`blackburn_2002_book`) which would dilute the briefing
  with mostly-unrelated content.
- **`baier_katoen_2008` part selection**: registered only `part04`, confirmed by reading (Def
  5.35 "Elementary Sets of Formulae", Thm 5.37 GNBA construction, state bound `2^|subf(ϕ)|`).
  Excluded 11 other parts whose keyword hits were false positives on inspection (different
  "closure" senses, general NBA background, or back-matter index entries).
- **Field convention**: every new entry carries both `relevance` (rendered by
  `literature-briefing.sh`) and `reason` (matching the file's existing convention), per the
  plan's F2 finding that the 33 pre-existing entries carry only `reason` and render nothing.
- **Acceptance criteria**: used the plan's replacement criteria (clean stderr, per-document
  title + `Relevance:` line, exact `seg_count` arithmetic, short-query reachability) rather than
  the task description's `sparse=false` check, which the plan's F3 finding showed passes before
  any work is done.

## Plan Deviations

- **venema_2001_sec04 duplicate-doc_id defect (caught and fixed)**: Phase 4 appended
  `venema_2001_sec04` as a new sub-index entry without checking whether it was already
  registered. It was — under task 408, for the unrelated Kamp-theorem research line, with only
  a `reason` field. The duplicate `doc_id` caused `literature-briefing.sh`'s
  `select(.doc_id == $id)` to match the pre-existing (relevance-less) copy first, so the new
  `relevance` never rendered — exactly the kind of failure Phase 6's discriminating criteria
  were designed to catch, and it did. Fixed by merging the two entries: the task-408 `reason` is
  preserved verbatim with one task-435 sentence appended, and the new `relevance` field was
  added to that same entry; the duplicate was removed. Net effect: 7 genuinely new documents
  were registered (not 8), and the final entry count is 40, not the naively-expected 41. Full
  provenance is recorded in the plan's Phase 4 post-hoc correction note and Phase 6 verification
  narrative.

## Verification

- Build: N/A (no build system for this task)
- Tests: N/A
- Files verified: Yes — `jq empty specs/literature-index.json` succeeds; 32 of the 33
  pre-existing entries are byte-for-byte unchanged (the 33rd, `venema_2001_sec04`, was
  deliberately corrected per the deviation above); `literature-briefing.sh` stderr is clean;
  all 8 target documents (7 new + the merged `venema_2001_sec04`) render both a title line and a
  `Relevance:` line; `<!-- lit-coverage mode=repo seg_count=40 sparse=false threshold=3 -->`
  matches the corrected arithmetic exactly; short-form `literature-search.sh` queries ("mosaic",
  "closure", "elementary sets") return hits inside the newly registered documents.

## Impacts

- A subsequent `--lit` dispatch on the dependent measure-design task (task 434's spawned
  successor) will now surface 8 termination-measure-relevant documents with design-specific
  relevance annotations, where the baseline sub-index had zero relevant coverage.
- Confirmed (F2 follow-up) that the 32 other pre-existing sub-index entries still render no
  `Relevance:` line — a real, pre-existing defect left as a follow-up, not fixed here, per the
  plan's Non-Goals.

## Follow-ups

- Backfill `relevance` onto the 32 remaining pre-existing sub-index entries (the Kamp-theorem /
  temporal-expressive-completeness research line) so their curation annotations actually render.
  Declared out of scope here to keep this task's diff reviewable (see plan Non-Goals).
- The global index's `id`/`doc_id` key heterogeneity (F1) and `baier_katoen_2008`'s duplicated
  `token_count` metadata (F6) remain unaddressed corpus-wide defects outside this task's
  `file_scope`.

## References

- `specs/435_curate_termination_literature_subindex/plans/01_curate-termination-subindex.md`
- `specs/434_discharge_mintpaysfortime_residual/reports/02_spawn-analysis.md`
- `specs/435_curate_termination_literature_subindex/progress/phase-1-progress.json` through
  `phase-6-progress.json`

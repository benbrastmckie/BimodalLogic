# Implementation Summary: Task #458

- **Task**: 458 - Migrate the 12 remaining legacy `chunks_dir`-only literature entries to the v2 schema
- **Status**: [COMPLETED]
- **Started**: 2026-08-18T13:50:00Z
- **Completed**: 2026-08-18T15:15:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: Task 457 (SCOPE 7 precedent, completed)
- **Artifacts**: plans/01_migrate-12-legacy-entries.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All twelve legacy `chunks_dir`-only entries in `~/Projects/Literature/index.json` were migrated
to the v2 schema by adding exactly five fields (`provenance_fidelity`, `path`, `token_count`,
`doc_type`, `source_format`) to each, following the plan's seven phases in order. Every
`provenance_fidelity` stamp rests on a hand read of at least one (up to ten, for the most
scrutinized entries) chunk file per document — no automated ratio or inference was used. The
mutation script's hard refusal precondition was exercised on a deliberately blanked copy before
running for real, and the post-mutation verification gate confirmed all 14 assertions pass,
including an independent token_count recomputation and a field-level diff against the
pre-mutation backup.

## What Changed

- `~/Projects/Literature/index.json` — five fields added to exactly twelve entries (outside this
  repo; not git-tracked). Backups: `index.json.bak-20260818-135342-pre-458` (master) and
  `index.json.bak-20260818-140334-pre-458-mutate` (immediate pre-mutation).
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/baseline.md` — new; live
  pre-migration baseline with PASS/DRIFTED verdicts.
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/targets12.tsv` — new; the
  twelve targets with live chunk counts.
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/adjudication.tsv` — new;
  per-entry chunk filenames, hand verdicts, proposed `provenance_fidelity`, `doc_type` evidence
  for all twelve.
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/scope5-12.tsv` — new;
  per-entry `doc_type`/`source_format` proposals with evidence and `EXCLUDE` sentinels.
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/migrate12_mutate.py` — new;
  the mutation script, with an allow-listed id/key set and a hard refusal precondition.
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/mutation_output.txt` — new;
  the script's captured before/after output for all twelve entries.
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-{1..7}-progress.json`
  — new; per-phase objective tracking and verification detail.
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/plans/01_migrate-12-legacy-entries.md`
  — all seven phase headings updated to their final status; `#### Reasoned Exclusions` table added
  to Phase 4's body; `#### Closeout Record` subsection added to Phase 7's body; Testing &
  Validation checklist fully checked off; plan-level `- **Status**:` updated to `[COMPLETED]`.

## Decisions

- Nine of the ten entries the research sampled as clean were confirmed clean on hand read
  (`verified_conversion`). `rumberg-zanardo-2019-transition-structures` reads clean in prose but
  drops isolated relation-symbol glyphs (consistent with a born-digital PDF's custom math-font
  extraction gap, not OCR misreading), so it was stamped `unverified_conversion` rather than
  `verified_conversion` — a finer distinction than "clean vs. degraded."
- Both Zotero PDFs (`rutten-2000-universal-coalgebra`, `rumberg-zanardo-2019-transition-structures`)
  were opened and confirmed same-work via `pdftotext` page-1 inspection before being used as
  `source_format: pdf` evidence, per Decision 1's constraint.
- The two BRICS technical reports (plus a third BRICS-series entry) received `doc_type: paper` as
  the nearest existing-vocabulary fit in the absence of a `report` value, with the reasoning
  recorded per-entry in `data/scope5-12.tsv` rather than defaulted.
- `reynolds-2003-ockhamist`'s systematic dropped-letter-`c` degradation (affecting the paper's own
  title) was judged worse than the enum's originating precedent ("formulas degraded, prose
  coherent") but still mapped to `unverified_conversion` as the nearest available value, per
  Decision 3; the imperfect fit is recorded as a gap rather than resolved by widening the enum.

## Plan Deviations

- **Phase 2 reclassification**: `thomason-1970-indeterminist-time` was expected by the research
  report to sample clean alongside the other nine. A 10-chunk hand read found genuine OCR
  letter-substitution errors ("unadomed" for "unadorned," an rn-to-m misread matching the same
  artifact family documented for `rutten-2000-universal-coalgebra`) and a proper-name misread
  ("Prier" for "Prior"), plus heavy formula corruption. It was reclassified as degraded
  (`unverified_conversion`) rather than forced into a clean stamp, exercising the plan's own
  Phase 2 Scope Hypothesis contingency for exactly this situation. See
  `progress/phase-2-progress.json`'s `deviations` entry and `data/adjudication.tsv`.
- No other deviations. All other phases followed the plan as written.

## Verification

- Build: N/A (data-only task; no code build)
- Tests: `bash .claude/scripts/literature-build-index.sh --global` exits 0, `chunks_fts` row count
  equals the Phase 1 live baseline (17736) exactly — stronger than the plan's `>=` floor
- Files verified: Yes — field-level diff, independent token_count recomputation (all 12 exact
  matches), Non-Goal field byte-identity, and `specs/literature-index.json` byte-identity all
  confirmed PASS in Phase 6 (`progress/phase-6-progress.json`, 14/14 assertions)

## Impacts

- All twelve entries are now schema-complete (v2) in the global literature index, closing the gap
  the task charter identified.
- Both freshly-stamped entries with a `pdf` source_format, and all twelve generally, still read as
  `unverified_summary` under `literature-search.sh`'s default ranking due to the pre-existing
  `sources/`-prefix defect in `load_fidelity_map()` (Decision 5) — confirmed as expected behavior,
  not a regression, via `--include-unverified` queries that did surface both tested entries.
- `specs/literature-index.json` (the sub-index) is untouched — none of the twelve appear there,
  confirmed byte-identical before and after.

## Follow-ups

- Backfill `title`/`authors`/`year` for the three entries with real Zotero bibliographic data
  already located (`thomason-1970-indeterminist-time`, `rutten-2000-universal-coalgebra`,
  `rumberg-zanardo-2019-transition-structures`); the remaining nine would need a fresh search.
- Fix the two carried-forward `sources/`-prefix code defects in `literature-fidelity-audit.sh` and
  `literature-search.sh`'s `load_fidelity_map()` (first documented in task 457's Phase 6; not
  re-diagnosed here).
- Resolve where `agent-system/`-sourced context documentation belongs in this repository (it has
  no `agent-system/` tree), then add the deferred "Partial v2 Migration for `chunks_dir`-only
  Entries" subsection to `literature-index.md`.
- Consider whether the corpus's six-value `provenance_fidelity` enum needs a value between
  "formulas degraded, prose coherent" (`unverified_conversion`'s originating use case) and
  "prose substantially degraded but still human-decodable" (what `reynolds-2003-ockhamist` and,
  to a lesser extent, `rutten-2000-universal-coalgebra` and the reclassified
  `thomason-1970-indeterminist-time` actually exhibit) — currently all collapse onto the same
  label.
- **Observation, not a follow-up for this task**: `specs/literature-index.json` carried a
  pre-existing, unrelated uncommitted 41-line addition (apparently task 435's Jonsson-Tarski/
  Blackburn/Goldblatt sub-index registration) at the start of this task's dispatch. This task's
  own mutations left the file byte-identical throughout; the foreign addition was neither touched
  nor committed here and remains uncommitted in the working tree for whichever task owns it.

## References

- Plan: `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/plans/01_migrate-12-legacy-entries.md`
- Research report: `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/reports/01_legacy-entries-v2-migration.md`
- Progress files: `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-{1..7}-progress.json`
- Prior precedent: `specs/457_repair_remaining_literature_corpus_data_defects/plans/01_corpus-data-repairs.md`

# Implementation Summary: Task #457

- **Task**: 457 - Repair the remaining Literature corpus data defects
- **Status**: [COMPLETED]
- **Started**: 2026-08-18T20:01:25Z
- **Completed**: 2026-08-18T22:00:00Z
- **Effort**: ~2 hours
- **Dependencies**: None
- **Artifacts**: plans/01_corpus-data-repairs.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Repaired six data defect classes (SCOPE 1-5, 7) in the global Literature corpus index at
`~/Projects/Literature/index.json` (369 entries) across seven sequential phases, each preceded by
a timestamped backup and followed by a JSON-parse / entry-count / diff-scope / FTS-rebuild gate.
SCOPE 6 (schema-consistency cleanup) was deferred per plan design, and four follow-up tasks were
spawned for work that is not a metadata repair (three planned: the 12-entry legacy-schema
coverage gap, and the two SCOPE 8 acquisition gaps; one discovered mid-implementation: an 8-entry
duplicate-id defect). All work stayed within the plan's Non-Goals boundary -- no file under
`.claude/**` or `agent-system/**` was touched.

## What Changed

- `~/Projects/Literature/index.json` (global corpus, not git-tracked) -- repaired in six mutation
  batches:
  - **SCOPE 1**: `diamondsareforever.path` corrected from a single `chunk_0001.md` fragment to
    `sources/diamondsareforever/`; `token_count` corrected from 95000 to 21755 (fresh
    `chars/4+20` over all 56 concatenated chunks).
  - **SCOPE 2**: `token_count` recomputed fresh for the three stub-extract entries
    (`fine_2012_guide-to-ground` -> 26772, `vardi_wolper_1986_automata_verification` -> 11716,
    `fine_2012_counterfactuals-without-possible-worlds` -> 15958).
  - **SCOPE 3**: `token_count` re-baselined on 96 entries -- 84 from the live drift worklist
    (regenerated against the post-Phase-2 index, not the Phase 1 snapshot) plus all 12
    `baier_katoen_2008_partNN` entries (a confirmed copy-paste-placeholder set, now 12 distinct
    values) plus 8 stale duplicate-id placeholder entries invisible to an id-keyed lookup (see
    Plan Deviations).
  - **SCOPE 4**: `authors` normalized from comma-joined strings to arrays on 60 entries via
    `literature-normalize-authors.sh --apply`; 5 of the 60 (the `hughes_1996` group) required a
    manual follow-up correction for a two-author single-element mis-split (see Plan Deviations).
  - **SCOPE 5**: `doc_type` and `source_format` filled on 35 v2-schema entries -- 29 with both
    fields (26 inherited from an already-populated `parent_doc`, plus 3 individually evidenced),
    6 with `doc_type` only, recorded as a `#### Reasoned Exclusions` table in the plan (no source
    file on disk, no `parent_doc`, no Zotero cross-reference).
  - **SCOPE 7**: `provenance_fidelity`, `path`, and `token_count` populated on the three
    newly-ingested legacy entries after a fresh manual chunk read of each: Jönsson & Tarski
    1951/1952 stamped `unverified_conversion` (prose coherent, formulas OCR-degraded, confirmed
    by hand), Goldblatt 2006 stamped `verified_conversion` (prose and symbols both clean,
    confirmed by hand across two chunks). `literature-fidelity-audit.sh` could not corroborate
    either verdict (see Follow-ups) -- the manual read was the sole evidence, as designed.
- `specs/state.json`, `specs/TODO.md` -- four follow-up tasks spawned (458-461).
- `specs/457_repair_remaining_literature_corpus_data_defects/plans/01_corpus-data-repairs.md` --
  all seven phases checked off and marked `[COMPLETED]`; plan-level status `[COMPLETED]`; a
  `#### Reasoned Exclusions` table added under Phase 5; a phase-notes addendum added under
  Phase 6 for the new code-level finding (see Follow-ups).
- `specs/457_repair_remaining_literature_corpus_data_defects/data/*` -- worklist generator
  (`gen_worklists.py`, reusable across phases) and per-phase mutation scripts, plus the
  regenerated worklists and `baseline.md`.
- `specs/literature-index.json` -- inspected for consistency in Phase 6, found already correct;
  **not edited** (the fidelity narrative for the Jönsson-Tarski pair and Goldblatt 2006 already
  matched the stamps written to the global index).

## Decisions

- Token-count formula `chars/4+20` applied uniformly across SCOPE 1, 2, 3, and 7, per Planning
  Decision 1; every recomputation was fresh at implementation time, never a replayed report
  figure (confirmed exact matches with research's cited figures for SCOPE 1/2 as an independent
  check, not a shortcut).
- SCOPE 3's drift ratio is `fresh / stored` (recomputed over stored), not the reverse -- this
  direction is what "all drift in the same direction" in the research/plan actually describes;
  an initial reversed-ratio pass in this implementation's own tooling produced a spurious,
  inflated count before the direction was corrected (see `data/baseline.md`'s "SCOPE 3
  divergence" section for the full root-cause writeup).
- SCOPE 6 deferred per Planning Decision 3, with the live post-repair counts (25 both-schema, up
  from 22 pre-repair as an expected side effect of Phase 6; 37 absolute-`chunks_dir`, unchanged)
  and the consumer scan (no `.claude/scripts/literature-*.sh` reads `chunks_dir` in preference to
  `path`) recorded in `progress/phase-7-progress.json`'s `scope6_deferral_record`.
- Phase 7 additionally filled `doc_type`/`source_format` on the three SCOPE 7 entries once Phase
  6's `path` addition newly exposed them to SCOPE 5's missing-fields pattern -- see Plan
  Deviations.

## Plan Deviations

- **Phase 3 (SCOPE 3)**: the regenerated 88-entry mutation target (84 drift + full 12-entry
  `baier_katoen` set) left 8 residual stored-0 entries after the main mutation pass. Root cause:
  the corpus carries 8 duplicate-id entries (same `id` appears twice) -- one instance a stale
  "migrated from ingest schema" placeholder (`token_count: 0`, empty summary), the other an
  already-correct, fully-populated v2 entry. An id-keyed lookup dict silently resolves duplicate
  keys to the last entry, hiding the stale duplicate. A supplementary pass
  (`data/phase3_dup_fix.py`) iterated the raw entries list to find and correct all 8 stale
  duplicates' `token_count`, closing SCOPE 3's defect-class-empty gate honestly. The duplicate-id
  structural defect itself (two records per document) is not one of SCOPE 1-8 and was not
  resolved here -- see Follow-ups (task 459).
- **Phase 4 (SCOPE 4)**: `literature-normalize-authors.sh --apply` mis-split 5 of the 60 entries
  (the `hughes_1996` group) into a single array element wrapping both authors
  (`["G. E. Hughes, M. J. Cresswell"]`) instead of two elements. Manually corrected post-apply to
  `["G. E. Hughes", "M. J. Cresswell"]` so the phase's own no-embedded-comma-join verification
  criterion holds. Four other pre-existing array entries retain an internal `", "` in a
  single-person "Lastname, First" format (`gabbay_2000`, the Jönsson-Tarski pair, Goldblatt
  2006) -- these are a different, legitimate name-formatting convention already accepted
  elsewhere in the corpus and were not part of SCOPE 4's string-to-array defect class, so they
  were left untouched.
- **Phase 7**: spawned a 4th, unplanned follow-up task (459) for the duplicate-id defect found in
  Phase 3, in addition to the plan's three named follow-ups (458, 460, 461). Also filled
  `doc_type`/`source_format` on the three SCOPE 7 entries as a bounded, evidence-grounded
  extension of Phase 6's own work (see Decisions).

## Verification

- Build: N/A (data-only task, no code build)
- Tests: N/A -- every mutation phase's own gate (JSON parse, entry-count-against-baseline,
  diff-touches-only-declared-fields, defect-class-now-empty, `literature-build-index.sh --global`,
  FTS row count) passed for all six mutation phases; final whole-corpus validation in Phase 7
  re-confirmed all six defect classes simultaneously against one final index read.
- Files verified: Yes -- 369 entries throughout, all six per-batch backups present and
  JSON-parseable, FTS row count held at 17736 (the Phase 1 baseline) through every rebuild.

## Impacts

- The global Literature corpus (`~/Projects/Literature/index.json`) is now free of the six
  repaired defect classes: no malformed chunk-path entries, no stub or drifted `token_count`
  values on `path`-carrying entries, no string-valued `authors`, no non-legacy entry missing
  `doc_type`/`source_format` outside the six reasoned exclusions, and the three newly-ingested
  legacy documents carry an honestly-adjudicated `provenance_fidelity`.
- Any `--lit`-mode consumer of this corpus now gets accurate token-budget accounting and correct
  `path` resolution for the repaired entries, and downstream Lean-citation work against the
  Jönsson-Tarski pair is protected by the `unverified_conversion` stamp (formulas must still be
  verified against the source PDF, exactly the `rabinovich_2014`-hazard-avoidance this phase was
  designed to prevent).
- Four follow-up tasks (458-461) are now discoverable in `specs/TODO.md` for the work this task
  deliberately did not do inline.

## Follow-ups

- **Task 458** -- migrate the remaining 12 legacy `chunks_dir`-only entries to the v2 schema,
  using Phase 6's adjudication process as the template.
- **Task 459** (unplanned, discovered mid-implementation) -- deduplicate 8 stale
  "migrated from ingest schema" placeholder entries sharing an id with an already-correct v2
  entry.
- **Task 460** -- acquire a usable copy of Gabbay/Kurucz/Wolter/Zakharyaschev 2003 (currently
  blocked by broken PDF font encoding in the Zotero copy).
- **Task 461** -- acquire Goldblatt 1989 "Varieties of complex algebras" (absent from both the
  corpus and Zotero).
- **New code-level finding, not fixed here (out of scope)**: `literature-search.sh`'s
  `load_fidelity_map()` hard-codes an assumption that any `provenance_fidelity`-bearing entry's
  `path` starts with the literal prefix `sources/`. The three SCOPE 7 entries' real location is
  directly under `LITERATURE_DIR` (the legacy online-ingest bridge, not `sources/`), so their
  honestly-populated `path` is silently skipped by this lookup, fail-opening their reported
  fidelity to `unverified_summary` in default `literature-search.sh` output --- including
  Goldblatt 2006, which is genuinely `verified_conversion` and should not be quarantined.
  `literature-search.sh --include-unverified` does surface all three correctly. This mirrors the
  five already-known code defects the plan's Overview places out of scope in the global
  agent-system repo; recommend a follow-up code task there to widen the dirname-extraction to
  also recognize online-ingest-bridge (non-`sources/`) paths. Full writeup in
  `progress/phase-6-progress.json`'s `new_code_level_finding` and the Phase 6 phase-notes
  addendum in the plan.

## References

- Plan: `specs/457_repair_remaining_literature_corpus_data_defects/plans/01_corpus-data-repairs.md`
- Research report: `specs/457_repair_remaining_literature_corpus_data_defects/reports/01_literature-corpus-data-repairs.md`
- Per-phase progress files: `specs/457_repair_remaining_literature_corpus_data_defects/progress/phase-{1..7}-progress.json`
- Worklists and baseline: `specs/457_repair_remaining_literature_corpus_data_defects/data/`

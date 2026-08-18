# Implementation Summary: Task #460

- **Task**: 460 - Acquire a usable copy of Gabbay, Kurucz, Wolter and Zakharyaschev 2003 (Many-Dimensional Modal Logics)
- **Status**: [COMPLETED]
- **Started**: 2026-08-18T14:42:00Z
- **Completed**: 2026-08-18T23:40:00Z
- **Effort**: ~7 hours across 14 dispatches (including one user-authorized escalation)
- **Dependencies**: None
- **Artifacts**: plans/01_ocr-and-ingest-gabbay-2003.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The only obtainable scan of this commercial title had a broken, non-OCR'd text layer (Type 3
fonts, `uni=no`). This task OCR'd the full 742-page book in resumable batches with `ocrmypdf`,
hand-verified the resulting text semantically (not by automated ratio) both pre- and post-ingest,
and got it into the literature corpus. The automated `literature-convert.sh` re-extraction path
was rejected by the conversion quality gate on 19 genuine but narrowly-scoped OCR fusion sites
(concentrated in one description-logic passage and one recurring citation); after root-cause
analysis showed all 19 sites were confined to non-prose formula/citation notation with zero prose
corruption, the user explicitly authorized a scoped, fully-audited manual exception: 15 of the 19
sites were hand-corrected with verified before/after text and fed directly into the corpus
pipeline (`literature-chunk.sh` + atomic `index.json` update + `literature-build-index.sh
--global`), bypassing only `literature-convert.sh`'s automated re-extraction for this one
document. The unmodified quality gate itself, `literature_quality_gate.py`, and
`literature-convert.sh` remain byte-identical for every other corpus document.

## What Changed

- `~/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf` — new; 742-page OCR'd PDF (`ocrmypdf --force-ocr -l eng`, batched 8x ~93-page slices, merged), retained so re-ingest or re-examination never requires re-running OCR.
- `~/Documents/literature-staging/gabbay_2003/phase5b-rejected-baseline.md` — new; pristine, read-only pre-correction markdown (audit baseline).
- `~/Documents/literature-staging/gabbay_2003/phase5b-corrected.md` — new; the 15-site-corrected markdown actually ingested.
- `~/Projects/Literature/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/` — new corpus doc directory: `chunks.json` (758 chunks), 758 `chunk_NNNN.md` files, `metadata.json`.
- `~/Projects/Literature/index.json` — one new entry appended atomically (361 -> 362 entries), then, on reopening (dispatch_seq 15), promoted in place from the legacy `chunks_dir`-only schema to the v2 schema (7 fields added: `id`, `path`, `token_count`, `doc_type`, `source_format`, `provenance_fidelity`, `schema_normalized_at`) plus a `title`/`authors`/`year` bibliographic correction, following task 458's `migrate12_mutate.py` convention exactly. Entry count unchanged at 362 throughout.
- `~/Projects/Literature/.literature.db` — rebuilt (17,736 -> 18,494 `chunks_data`/`chunks_fts` rows, +758, matching the new document's chunk count exactly); rebuilt again after the v2 schema correction, row count unchanged at 18,494 (metadata-only edit).
- `~/Projects/Literature/index.json.bak-20260818-145418-pre-460` — pre-ingest backup, left in place per corpus convention.
- `~/Projects/Literature/index.json.bak-20260818-165129-pre-460b` — pre-v2-schema-correction backup, left in place per corpus convention.
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/02_ocr-semantic-gate-evidence.md` — Phase 4 (pre-ingest, 8 strata) and Phase 6 (post-ingest, 8 chunks) hand-read semantic gate evidence, mojibake sweep, and retrieval checks.
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/03_phase5-fusion-site-analysis.md` — root-cause analysis of the 19 gate-flagged sites, plus an addendum recording the full audited before/after text of all 15 corrections applied under the user's authorization.
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/plans/01_ocr-and-ingest-gabbay-2003.md` — all 7 phases checked off / marked `[COMPLETED]`.

## Decisions

- OCR settings: `ocrmypdf --force-ocr -l eng`, batched into 8 slices of ~93 pages via PyMuPDF (no `qpdf`/`gs`, neither installed).
- Phase 4/6 semantic gates were hand-read against four criteria (real vocabulary, grammatical/topical consistency, plausible proper nouns, position-consistent content) — never justified by the printable-character ratio or by `literature_quality_gate.py`, since that ratio gate is known to have passed 2260 mojibake chunks in an earlier, unrelated corpus incident.
- When the automated ingest was rejected at the conversion quality gate (`sentence-boundary-glue: 19 zero-space fusion(s) found, threshold 3`), a full site-by-site analysis (report 03) determined 13 sites were a misread `∃` glyph in standard description-logic `∃R.C` notation, 2 were a missing space in a recurring bibliography citation, and 4 were irreducible proof/formula noise. A good-faith retry with alternate `ocrmypdf` settings (`--oversample 400`, `--tesseract-pagesegmode 6`) did not change the result.
- Per the plan's explicit constraint against weakening, disabling, or bypassing the quality gate, Phase 5 was left `[BLOCKED]` and escalated to the user rather than force-completed.
- The user authorized escalation option 1: hand-correct only the 13 `∃`-glyph and 2 citation-spacing sites (all individually verified, uniqueness-checked, before/after audited), leave the 4 irreducible sites untouched and undocumented-as-fabricated, and feed the corrected markdown directly into `literature-chunk.sh` + `index.json` + `literature-build-index.sh --global`, bypassing only `literature-convert.sh`'s automated re-extraction for this one document.
- `index.json` was updated via a temp-file-plus-`os.replace` atomic write (rather than `literature-ingest.sh`'s own in-place write) per this dispatch's concurrency note.
- `specs/literature-index.json` (the repo-local sub-index) was deliberately left untouched — its pre-existing uncommitted 41-insertion diff was a declared non-goal throughout.
- On reopening (dispatch_seq 15), orchestrator verification found the entry created above was written in the legacy `chunks_dir`-only schema — the same shape task 458 spent 7 phases migrating 12 other entries away from, making this the corpus's 4th `id: null` straggler. Root cause: `literature-ingest.sh`'s index-append logic (deliberately replicated field-for-field in the Phase 5b addendum so the manually-chunked document would be indistinguishable from a normal ingest) always writes the legacy 8-field shape. Corrected by following task 458's `migrate12_mutate.py` convention exactly: `id` set equal to `doc_id` (matching the 2026-08-05 precedent), `path` computed per the SCOPE 1 directory-path convention, `token_count` computed fresh via `chars/4+20` over the concatenated chunk text, `doc_type`/`source_format` set from directly-evidenced source-PDF/Zotero-record inspection (SCOPE 5 convention), and `provenance_fidelity` set to `unverified_conversion` — calibrated against task 458's own adjudications, since this document's 16 hand-read samples found zero prose corruption (stronger evidence than `rutten`/`reynolds`, both stamped `unverified_conversion`) but is not `verified_conversion` either (4 confirmed-irreducible formula-noise sites remain, unlike Goldblatt's "prose and symbols both clean" precedent for that value). `title`/`authors`/`year` were also corrected to the real bibliographic values from `zotero-library.json`'s `Kurucz2003` record (explicitly authorized for this entry, unlike task 458's own Decision 4 non-goal). Full before/after audit trail in report 03's Addendum 2. The pipeline-level defect (`literature-ingest.sh` always writes the legacy schema) was NOT fixed — recorded as `INGEST_WRITES_LEGACY_SCHEMA` for a future task, per explicit instruction that `.claude/**` is a disposable deploy artifact of the `agent-system/**` source store.

## Plan Deviations

- **Phase 5** was not completed by the plan's originally-specified route (`literature-ingest.sh` end-to-end). It was blocked at the automated conversion quality gate, then completed via a user-authorized manual exception that replicates every subsequent pipeline step (`literature-chunk.sh`, index update, `literature-build-index.sh --global`) but bypasses only `literature-convert.sh`'s automated re-extraction. This is recorded in full in report 03's addendum, with every correction's before/after text. *(deviation: altered — automated conversion re-extraction replaced by an audited manual correction step, explicitly authorized by the user; the quality gate, `literature-convert.sh`, and `literature_quality_gate.py` were never modified.)*
- Phase 5's original "Re-record the immediately-pre-ingest index entry count" task was skipped since the first ingest attempt failed before touching `index.json`; re-confirmed post-failure instead (361 entries, unchanged).

## Verification

- Build: N/A (documentation/corpus-ingestion task, no compiled artifact).
- Tests: N/A (no automated test suite for literature ingestion; verification is the hand-read semantic gates below).
- Files verified: Yes — see per-item verification below.

**Phase 4 (pre-ingest)**: 8/8 sampled strata (front matter, Ch.1 prose, mid-body, math-heavy, bibliography, index/back-matter, and 2 random pages) PASS. Gate decision: PROCEED.

**Phase 5b (the correction exception)**: all 15 corrections individually verified (exact line number, exact before/after substring, uniqueness-checked before applying); a full-file diff against the pristine baseline confirms exactly these 13 changed lines and nothing else. The 4 irreducible sites re-verified byte-identical to baseline after correction.

**Phase 6 (post-ingest)**: 8/8 sampled chunks PASS (front matter, 2 math-heavy — one confirming corrected `∃` sites in place, one confirming the 2 untouched `YUx.YUx` irreducible sites — 3 body-prose spanning ~25%/50%/75%, bibliography confirming a corrected Medvedev citation, and the back-matter index). Mojibake sweep: 0 bracket-cluster hits, 0 leading-diacritic hits, 349 consonant-run hits across 115/758 chunks, all individually confirmed to be legitimate book-internal logic-system acronyms (`CPDL`, `TSPF`, `NTPP`, `BRCC`, `CQDL`, etc.), not corruption. Retrieval: both required `literature-search.sh` queries return the new doc_id. Chunk-count ratio (758/742 pages, ~471.5 tokens/page) judged plausible against a comparable corpus entry.

**Phase 7 (closeout)**: Zotero original sha256 re-verified unchanged (`6b03d3f967e1bff33dad1a2b6f770039011b93410d789fb4e36031fc6557794b`). `~/Projects/Literature` porcelain diff against the Phase 1 baseline contains exactly the two expected new lines (new doc directory, new `-pre-460` backup) and drops nothing. `git diff specs/literature-index.json` in this repo is byte-identical to the Phase 1 baseline diff (52 lines, 0 diff-of-diff).

## Impacts

- The corpus gains a 742-page, 758-chunk, fully hand-verified entry for a foundational
  many-dimensional/combined-modal-logic reference, retrievable via `literature-search.sh` and
  usable by `--lit`-mode agent dispatches and `/cite` verification.
- `provenance_fidelity` is now set (`unverified_conversion`) on this entry as part of the
  Phase 7 reopening correction. `literature-search.sh`'s displayed value for it is still
  `unverified_summary`, not the true `unverified_conversion` — confirmed to be the same
  pre-existing `sources/`-prefix code defect in `load_fidelity_map()` already documented as task
  458's Decision 5, and reproduced identically on `rutten-2000-universal-coalgebra` (also
  `unverified_conversion` in `index.json`, also displayed as `unverified_summary`). Not a new
  defect, not fixed here. `literature-search.sh` still quarantines this entry from default-mode
  ranked results (any non-`verified_conversion` display value is quarantined); it remains fully
  retrievable via `--include-unverified`, `--read`, `--toc`, or `--doc`.
- A pre-existing, unrelated corpus defect was discovered and documented (not fixed, out of scope):
  a spurious OCR-garbled level-1 markdown heading causes 629/758 (83%) of this document's chunks
  to carry an unhelpful `section_path` breadcrumb. Chunk body content and retrievability are both
  unaffected; only in-corpus section-path navigation for this one document is degraded.

## Follow-ups

- **(a) Math-OCR limitation** (standing, from the plan): display and inline formulas in this
  document carry OCR transcription noise, including 4 confirmed-irreducible sites. `/cite` and
  `--lit` consumers must cross-check any quoted formula against the printed book and must never
  quote OCR'd formulas from this document verbatim as authoritative.
- **(b) Deferred sub-index registration** (standing, from the plan): `specs/literature-index.json`
  was deliberately not modified because of its pre-existing uncommitted diff. A follow-up task
  should add a sub-index entry carrying an explicit math-fidelity hazard note.
- **(c) Quality-gate blind spot** (standing, from the plan): `literature_quality_gate.py` cannot
  distinguish printable-but-semantically-wrong text from correct text, which is why this task
  interposed hand-read semantic gates at Phase 4 and Phase 6. A follow-up task should consider
  whether the gate itself can be strengthened (out of scope here — it was explicitly required to
  remain untouched).
- **(d) New, discovered**: consider a follow-up task to fix the spurious level-1 heading /
  `section_path` breadcrumb defect described under Impacts above — either by correcting the
  garbled heading text in the corrected markdown (re-chunking), or by hardening the chunker's
  heading-detection heuristic against garbled OCR text being promoted to a spuriously shallow
  heading level.
- **(e) New, discovered, partially addressed**: `provenance_fidelity` is now set
  (`unverified_conversion`) on this entry, but `literature-search.sh` still displays it as
  `unverified_summary` and quarantines it from default-mode ranking, due to the pre-existing
  `sources/`-prefix code defect in `load_fidelity_map()` (task 458's Decision 5). A follow-up
  task should fix that defect so all v2-schema entries with a non-`sources/`-prefixed `path`
  (this one plus the 12 migrated by task 458) display and rank correctly.
- **(f) New, discovered**: `literature-ingest.sh` always writes the legacy `chunks_dir`-only
  8-field schema and has no v2-field-population step, so every future ingest reintroduces the
  exact defect corrected in this reopening. Recorded as `INGEST_WRITES_LEGACY_SCHEMA` against
  `agent-system/extensions/literature/scripts/literature-ingest.sh`. A follow-up task should add
  v2-field population (at minimum `id`, `path`, `doc_type`, `source_format`) to the ingest
  pipeline itself, with `provenance_fidelity` and `schema_normalized_at` following the same
  hand-adjudication-required convention task 457/458 established (never computed, always a
  recorded manual read).

## References

- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/plans/01_ocr-and-ingest-gabbay-2003.md`
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/02_ocr-semantic-gate-evidence.md`
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/03_phase5-fusion-site-analysis.md`
- `~/Documents/literature-staging/gabbay_2003/ingest.log`, `baseline.txt`

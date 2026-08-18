# Phase 1 Baseline — Task 457 (Repair the remaining Literature corpus data defects)

Recorded: 2026-08-18T20:01Z (backup timestamp `20260818-130156`)

## Prerequisites

- `python3` (3.13.13), `jq` (1.8.1), `sqlite3` (3.51.2) — all present.
- `.claude/scripts/literature-normalize-authors.sh`, `literature-build-index.sh`,
  `literature-fidelity-audit.sh` — all present and executable (`-rwxr-xr-x`).

## Index baseline

- `~/Projects/Literature/index.json`: **369 entries**, JSON parses clean, top-level keys
  `version, description, token_budget, max_chunks, entries` (matches expected shape). `version`
  field value: 2.
- `specs/literature-index.json`: parses clean (separate, 45-entry sub-index; unaffected by this
  phase — read-only).

## FTS baseline

- `~/Projects/Literature/.literature.db` `chunks_fts` row count: **17736**.
- Sample query `literature-search.sh "modal logic"` returns ranked hits (confirmed non-empty,
  top result `zakharyaschev_2001` / `biermandepaiva_2000_onanintuitionisticmodallogic`).

## Backups taken (task-level, pre-457)

- `~/Projects/Literature/index.json.bak-20260818-130156-pre-457` — JSON-parse verified OK.
- `specs/literature-index.json.bak-20260818-130156-pre-457` — JSON-parse verified OK.

Both source files verified byte-identical to their state at phase start (no mutation occurred
during worklist generation — all scans are read-only).

## Live worklist generation — per-scope PASS/DRIFTED verdict

| Scope | Report count | Task said | **Live count** | Verdict | Notes |
|-------|-------------|-----------|----------------|---------|-------|
| SCOPE 1 (chunk-path entry) | 1 | 1 | **1** (`diamondsareforever`) | PASS | Exact match. |
| SCOPE 2 (stub extracts) | 3 | 3 | **3** (all 3 named IDs found) | PASS | Exact match. |
| SCOPE 3 (drifted token_count, excl. 1/2) | 56 | "roughly 52" | **84** | **DRIFTED** (+50% vs report) | See "SCOPE 3 divergence" below — not a stop condition, per this phase's own Scope Hypothesis instruction for SCOPE 3 ("record the actual, and flag anything outside it"); Phase 3 re-derives live and applies the falsifier check before writing. |
| SCOPE 4 (comma-joined authors) | 60 | — | **60** | PASS | Exact match; `literature-normalize-authors.sh` dry run confirms 60 proposed normalizations, 0 malformed-array entries. |
| SCOPE 5 (missing doc_type+source_format) | 35 (50 naive − 15 legacy) | — | **35** | PASS | Naive count 50 (35 + 15 legacy) reconfirmed live; all 35 missing both fields together (none missing only one). |
| SCOPE 6 (both-schema / absolute chunks_dir) | 22 / 37 | — | **22 / 37** | PASS | Exact match on both sub-counts (deferred scope, recorded for Phase 7). |
| SCOPE 7 (legacy chunks_dir-only) | 15 total, 3 named | — | **15 total, 3 named** | PASS | The 3 named (by title+year match, not id-substring): `j_nsson_and_tarski_-_1951_-_boolean_algebras_with_operators._part_i`, `j_nsson_and_tarski_-_1952_-_boolean_algebras_with_operators._part_ii`, `goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution` (title "Mathematical modal logic: A view of its evolution", year 2006 — confirms this is "Goldblatt 2006", distinct from `goldblatt_2003` the Erdős-graphs paper). 12 remaining unnamed legacy entries confirmed (matches the coverage-gap follow-up task scope).

### `baier_katoen_2008` uniform-placeholder sub-finding

All 12 `baier_katoen_2008_partNN` entries still share **one identical stored `token_count` value:
39848**. Confirms the copy-paste-placeholder hypothesis; included within the SCOPE 3 live count
above (not double counted separately).

### SCOPE 3 divergence — investigated, not a corpus-read error

The live re-derivation used the plan's own `chars/4+20` formula and found 84 entries diverging by
more than 20%, not "roughly 52-56". Root-caused before writing this file (methodology fix, not a
live-corpus anomaly):

1. **Direction correction**: the drift ratio must be computed as `fresh / stored` (recomputed
   over stored), not `stored / fresh`. Under this (correct) direction, **50 entries fall in the
   1.20–1.35 band**, closely matching the report's "44 in the 1.20–1.35 band" — the report's
   own recomputation used the same direction; an initial reversed-ratio pass in this phase's
   tooling produced a spurious ~85% inflated count before the direction bug was caught and fixed.
2. **A genuinely new sub-population the report did not find: 26 entries with a stored
   `token_count` of exactly 0** despite carrying substantial live content (`blackburn_2002_book`:
   0 stored vs. 360,886 fresh; `johnstone_2002_sketches_of_an_elephant_vol2`: 0 stored vs. 478,221
   fresh; 24 others). These are legitimate members of the SCOPE 3 defect class (a stored value of
   0 diverges from any nonzero fresh count by definition) and were apparently missed by the
   report's own recomputation pass. They are **not** a corpus-read bug in this phase's tooling —
   each was spot-verified by reading the entry's own JSON record directly (see e.g.
   `blackburn_2002_book`, whose `"token_count": 0` is visible on direct inspection).
3. **Net live count**: 58 entries with a defined, out-of-band ratio + 26 zero-stored entries =
   **84 entries total**, of which 2 drift in the reverse direction (`gabbay_1994_ch10_sec03`,
   `mendelson_2016_ch03`, both ~0.82-0.83, barely outside the 0.833 symmetric cutoff — noted as
   minor exceptions to "all in the same direction," not evidence of a methodology error).

Per this phase's own Scope Hypothesis clause for SCOPE 3 ("treat 52-56 as the expected range,
record the actual, and flag anything outside it in the phase notes" — this is the specific,
scope-local override of the general ±10%-divergence stop rule), this divergence is recorded here
rather than treated as a blocking condition. Phase 3 re-derives this worklist fresh against the
post-Phase-2 index and re-applies the falsifier spot-check before writing.

### SCOPE 5 doc_type/source_format proposal (evidence-grounded, for Phase 5 consumption)

Of the 35 entries: 23 inherit `doc_type=chapter, source_format=pdf` from a `parent_doc` whose own
fields are already populated (7 `church_1956_ch*`, 5 `gentzen_1935_sec*`, 4 `hughes_1996_p*`,
6 `mendelson_2016_ch*`, 4 `zakharyaschev_2001_sec*` — wait, count check: 7+5+4+6+4=26, not 23; see
`scope5-missing-fields.tsv` for the authoritative per-entry table). `gabbay_1994_ch10` has no
`parent_doc` field but its sibling directory `gabbay_1994/` contains
`Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf`, the evident source of
its `.md` conversion — proposed `chapter`/`pdf`. `proofs_and_types` (Girard's *Proofs and Types*,
1989) and `van_doorn_2015_propositional_calculus_coq` both have a `.pdf` found directly in their
own source directory — proposed `book`/`pdf` and `paper`/`pdf` respectively. The remaining 6
(`bentzen_2023`, `from_2022`, `henkin_1949`, `johansson_1937`, `post_1921`, `trufas_2024`) have no
`parent_doc`, no source file on disk, and no `zotero_key`/`zotero_path` to cross-reference —
proposed `doc_type=paper` (all read as standalone academic papers from title/summary) with
`source_format` recorded as a **Reasoned Exclusion** in Phase 5, not guessed.

## No mutation occurred in this phase

`~/Projects/Literature/index.json` and `specs/literature-index.json` are unchanged from phase
start (all worklist generation is read-only; backups are the only new files written outside
`data/`).

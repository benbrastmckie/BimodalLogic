# Research Report: Task #459

**Task**: 459 - Deduplicate stale literature entries in ~/Projects/Literature/index.json
**Started**: 2026-08-18T00:00:00Z
**Completed**: 2026-08-18T00:00:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**:
- `~/Projects/Literature/index.json` (live, re-derived counts)
- `~/Projects/Literature/.claude/scripts/literature-build-index.sh` (read in full)
- `~/Projects/Literature/<doc-dir>/chunks.json` manifests (existence/shape check)
- `specs/literature-index.json` (repo sub-index, read-only)
- Live `sqlite3` inspection of `.literature.db` after a fresh `--global` build
**Artifacts**:
- This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Every number in the task description still holds under live re-derivation: 369 total entries,
  361 distinct ids, exactly 8 duplicated ids, and they are exactly the 8 named in the description.
  Task 458's mutation of 12 unrelated entries did not touch this duplicate set.
- The stale-vs-populated characterization holds uniformly across all 8 pairs, but the description's
  detail "`token_count=0`" for the stale side is now **stale itself**: a prior task already
  corrected `token_count` on the stale entries, so both sides of every pair now show matching
  non-zero `token_count`. The still-valid discriminator is `provenance == "migrated from ingest
  schema (doc_id/source_path/chunks_dir)"` (present only on the stale side) vs. its absence
  (populated side), corroborated by empty `summary`, thinner `keywords`, surname-only `authors`,
  and the extra `chunk_count`/`ingested_at` fields on the stale side.
- `literature-build-index.sh --global` **never reads `index.json`**. It globs the filesystem for
  `chunks.json` manifests under `~/Projects/Literature` and builds `.literature.db` purely from
  those on-disk manifests and chunk files. This is now empirically confirmed (full script read +
  a live `--global` run), not just cited from a prior investigation.
- Consequence: deleting a stale duplicate *metadata record* from `index.json` cannot change the
  FTS row count, because nothing about the FTS build path is index.json-driven, and because each
  of the 8 docs has exactly **one** `chunks.json` manifest and **one** on-disk directory (no chunk
  duplication to begin with). The FTS-row-count "gate" in the task's acceptance criteria is
  real (it will still run and exit 0) but is **not actually sensitive to this deletion at all** —
  it is a trivially-passing check for this specific dedup, not a meaningful regression gate.
- Live FTS baseline just established (this session, `--global` rebuild): exit 0, 170 manifests
  found, 18,432 chunks processed into `chunks_data`, **17,736** rows in `chunks_fts` after
  rebuild, 168 distinct `doc_id`s. Use 17,736 as the row-count floor for the post-dedup check
  (or 18,432/168 if the implementer prefers the pre-FTS-rebuild `chunks_data`/distinct-doc
  counts — see Risks below for why these three numbers differ).
- None of the 8 duplicated ids appear in the repo's `specs/literature-index.json` sub-index (which
  has 45 entries, all unrelated). That file also carries a pre-existing uncommitted modification
  from unrelated work — left untouched, only inspected.

## Context & Scope

Re-derive, live, whether the 8 duplicate ids named in the task description are still the correct
and complete set of duplicates in `~/Projects/Literature/index.json`, verify the stale-vs-populated
characterization per pair (not assumed), determine what `literature-build-index.sh --global`
actually reads (to assess whether the FTS-row-count acceptance check is meaningful for this
deletion), check whether the two entries in each pair share a `path`/`chunks_dir`, and check the
repo sub-index for overlap. No files were mutated — `index.json` was read-only throughout; the
only write performed was a `.literature.db` rebuild, which the script's own header documents as
an ephemeral, disk-rebuildable artifact (atomic tmp-then-rename), not a source-of-truth mutation.

## Findings

### Live counts (re-derived, not trusted from the description)

```
total entries:            369
distinct ids (id field):  361  (366 entries carry an `id` field; 3 carry only `doc_id`)
duplicated ids:            8
```

The 3 entries that carry `doc_id` instead of `id` —
`j_nsson_and_tarski_-_1951_-_boolean_algebras_with_operators._part_i`,
`j_nsson_and_tarski_-_1952_-_boolean_algebras_with_operators._part_ii`, and
`goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution` (index positions 366-368,
`ingested_at`/timestamps all dated 2026-08-18, i.e. today) — are **not** duplicated and are
**out of scope** for this task. They use the newer/older raw ingest-schema shape but each appears
exactly once. Do not conflate them with the 8-pair cluster; they sit immediately after it in the
array (positions 366-368 vs. the cluster at 344-361) and are unrelated leftovers from today's
literature ingest activity, not part of the migration-duplication problem this task addresses.

The 8 duplicated ids, confirmed identical to the task description's list:

```
brookes_2007_semantics-concurrent-separation-logic
calcagno_2007_local-action-abstract-separation-logic
docherty_pym_2019_stone-dualities-separation-logics
jipsen_litak_2017_algebraic-glimpse-bunched-implications
jung_2018_iris-from-the-ground-up
ohearn_2007_resources-concurrency-local-reasoning
ohearn_2019_separation-logic-cacm
reynolds_2002_separation-logic
```

Each appears exactly twice; no id appears 3+ times.

### Per-pair verification of the stale-vs-populated story

All 16 entries (8 pairs) sit in one contiguous block of the array, indices 344-361 (interleaved
with two singleton populated entries at 358-359, `pym_ohearn_yang_2004_possible-worlds-resources-bi`
and `ishtiaq_ohearn_2001_bi-assertion-language`, which have no stale counterpart and are not part
of this task). Full table (array index / stale vs. populated):

| id | stale idx | populated idx |
|---|---|---|
| calcagno_2007_local-action-abstract-separation-logic | 344 | 353 |
| docherty_pym_2019_stone-dualities-separation-logics | 345 | 354 |
| jung_2018_iris-from-the-ground-up | 346 | 355 |
| ohearn_2007_resources-concurrency-local-reasoning | 347 | 352 |
| ohearn_2019_separation-logic-cacm | 348 | 351 |
| reynolds_2002_separation-logic | 349 | 350 |
| brookes_2007_semantics-concurrent-separation-logic | 356 | 360 |
| jipsen_litak_2017_algebraic-glimpse-bunched-implications | 357 | 361 |

In every pair the stale entry's array index is lower than the populated entry's. This is a
structural regularity but not guaranteed to survive future edits — a deletion script should key
off `provenance`/field-shape, not index order.

Per-pair field comparison, uniform across all 8 (spot-checked in full, not sampled):

- **Stale side** — `provenance: "migrated from ingest schema (doc_id/source_path/chunks_dir)"`,
  `summary: ""` (empty string, all 8), `authors` = surname-only single string (e.g. `["Calcagno"]`
  vs. `["Cristiano Calcagno", "Peter W. O'Hearn", "Hongseok Yang"]`), fewer `keywords` (2-5 vs.
  6-8 on the populated side), and two extra fields not present on the populated side: `chunk_count`
  and `ingested_at`.
- **Populated side** — no `provenance` key at all (not `null` — the key is absent), non-empty
  `summary` (148-198 chars across the 8), full author names, richer `keywords`, and two extra
  fields not present on the stale side: `parent_doc` and `project_tags` (plus `zotero_path`, which
  the stale side also lacks).
- **`token_count`**: identical between the two sides of every pair (e.g.
  `calcagno_2007_...` = 12110 on both). This confirms the task description's claim that "a prior
  task corrected the stale duplicates' token_count only" — the `token_count=0` detail in the
  original task description is no longer true for any of the 8 pairs; the safe discriminator is
  `provenance` field presence, not `token_count`.
- **`path`**: identical string between the two sides of every pair (e.g. both entries for
  `brookes_2007_...` carry `path: "brookes_2007_semantics-concurrent-separation-logic/"`).
  Confirmed for all 8 pairs, not assumed.
- **`chunks_dir`**: neither side of any of the 8 pairs carries a `chunks_dir` key at all (it is
  absent, not present-and-shared). `chunks_dir` is a field used only by the *unrelated* raw
  ingest-schema entries (e.g. the 3 `doc_id`-only entries at 366-368) — none of the 8 duplicate
  pairs use it. `path` is the field to compare for these 8.

### What `literature-build-index.sh --global` actually reads (verified, not assumed)

Full script at `~/Projects/Literature/.claude/scripts/literature-build-index.sh` (identical copy
deployed at `/home/benjamin/Projects/BimodalLogic/.claude/scripts/literature-build-index.sh`) was
read end-to-end. Confirmed mechanism:

1. `--global` sets `TARGET_DIRS=("$HOME/Projects/Literature")` (or `$LITERATURE_DIR` override).
2. `build_index_for_dir` does `mapfile -t manifests < <(find "$target_dir" -name "chunks.json" | sort)`
   — a pure filesystem glob for `chunks.json` files, nothing JSON-index-related.
3. For each manifest, it opens the manifest's own `chunks.json` (a list of chunk records with
   `chunk_id`, `doc_id`, `source_path`, etc.), reads each chunk's source text file for an FTS
   content preview, and `INSERT OR REPLACE`s into `chunks_data`, then rebuilds the `chunks_fts`
   FTS5 index from that table.
4. **`index.json` is never opened, read, or referenced anywhere in this script.** grep-level
   confirmation: no `index.json`, `entries`, or similar identifiers appear in the file.

This is now directly verified (not inherited from a prior investigation's claim). It settles the
open question: the FTS row-count check in the task's acceptance criteria is a real, executable
gate (the script runs and reports a row count) but it is **not sensitive to an index.json edit at
all** for this specific deletion, because:
- The two entries in each pair are metadata-only records pointing at the *same* `path`, and that
  path has exactly one physical directory and exactly one `chunks.json` manifest on disk (verified
  for all 8 — see next section). There is no "second copy" of chunks to lose.
- Even in principle, index.json entry count and FTS row count are on completely independent code
  paths — one is bash+jq/python JSON-list surgery, the other is a `find`-driven manifest walk.

Practical implication for the implementation phase: "FTS row count >= baseline" is a correct
safety net against *accidentally deleting/touching chunk files* while doing this task, but it will
pass trivially (with an unchanged row count) if the implementer does the deletion correctly as a
pure index.json edit. It should not be read as evidence that the index.json edit "worked" beyond
protecting against filesystem-level side effects — the entry-count-drops-369-to-361 check and the
JSON-still-parses check are the two gates that actually verify *this* task's outcome.

### Chunks/path sharing per pair (verified for all 8, not sampled)

For every one of the 8 ids, both entries' `path` fields are byte-identical strings, and exactly
one directory of that name exists under `~/Projects/Literature/` with exactly one `chunks.json`
manifest inside it:

| id | on-disk dir exists | chunks.json chunk count |
|---|---|---|
| brookes_2007_semantics-concurrent-separation-logic | yes (108 files) | 106 |
| calcagno_2007_local-action-abstract-separation-logic | yes (37 files) | 35 |
| docherty_pym_2019_stone-dualities-separation-logics | yes (106 files) | 104 |
| jipsen_litak_2017_algebraic-glimpse-bunched-implications | yes (109 files) | 107 |
| jung_2018_iris-from-the-ground-up | yes (163 files) | 161 |
| ohearn_2007_resources-concurrency-local-reasoning | yes (86 files) | 84 |
| ohearn_2019_separation-logic-cacm | yes (52 files) | 50 |
| reynolds_2002_separation-logic | yes (54 files) | 52 |

Since each pair points at one shared directory with one manifest, **deleting either the stale
metadata record (correct) or, hypothetically, the populated one (incorrect) would have zero effect
on chunk files or the FTS build** — confirming again that the FTS check is not the meaningful
gate here; entry-count and per-field correctness are.

### Live FTS baseline (established this session)

Ran `literature-build-index.sh --global` (read-only w.r.t. `index.json`; rebuilds the ephemeral
`.literature.db` via the documented atomic tmp-then-rename):

```
[build-index] Found 170 manifests in /home/benjamin/Projects/Literature
[build-index] Rebuilding FTS index for 18432 chunks...
[build-index] Resolving cross-references...
[build-index] Indexed: 18432 chunks, 0 cross-refs resolved, 11700 total relations, 55960KB database
[build-index] Database ready: /home/benjamin/Projects/Literature/.literature.db
[build-index] All indexes built successfully
exit 0
```

Post-build `sqlite3` counts:
- `chunks_fts` rows: **17,736**
- `chunks_data` rows: 18,432
- distinct `doc_id` in `chunks_data`: 168

The `chunks_fts` (17,736) vs. `chunks_data` (18,432) discrepancy (696 rows) is caused by
duplicate `chunk_id` values across different manifests being collapsed by `INSERT OR REPLACE`
into `chunks_data` before the FTS rebuild — this is a pre-existing characteristic of the corpus
unrelated to this task's 8 ids (170 manifests but only 168 distinct `doc_id`s already signals at
least one other doc-level duplication elsewhere in the corpus, outside this task's scope). It is
noted here only so the implementer picks the right floor: **use 17,736 as the post-dedup
`chunks_fts` floor** (it is the number the task's own acceptance-criteria language — "FTS row
count" — actually refers to); do not be alarmed if `chunks_data`'s 18,432 doesn't match.

### Repo sub-index overlap (read-only check)

`specs/literature-index.json` (in this repo) has 45 entries; none of the 8 duplicated ids are
among them (checked all 8 explicitly). This confirms the task's scope is entirely confined to the
global `~/Projects/Literature/index.json` — no changes needed in the repo sub-index.

That file (`specs/literature-index.json`) currently carries a pre-existing uncommitted
modification (`git status --porcelain` shows ` M specs/literature-index.json`) from unrelated
work, per the task description's own note. Left completely untouched; only inspected read-only.

### Git state of the global index (informational)

`~/Projects/Literature` is itself a git repo. `index.json` there is currently modified but
uncommitted (`git status --porcelain` shows ` M index.json`), most recently against a commit
`782ca166 index: migrate 17 ingest-schema records to the curated schema`. The 8-pair duplication
this task addresses is a residue of that (or a similar) earlier migration commit that added the
populated v2 records without removing the stale placeholders. Whoever implements the deletion
should be aware the working tree is already dirty from unrelated activity (today's ingests of the
Jónsson-Tarski and Goldblatt sources) — a `git diff -- index.json` before and after the dedup edit
will need to be read carefully to isolate just the 8 deletions from the pre-existing diff noise.

## Decisions

- The 8 ids to deduplicate are confirmed unchanged from the task description; no id should be
  added to or removed from that list.
- The correct entry to delete in each pair is the one carrying
  `provenance: "migrated from ingest schema (doc_id/source_path/chunks_dir)"` — this is the
  sole reliable, still-valid discriminator (the array-index-ordering regularity and the
  now-fixed `token_count` are corroborating signals only, not primary keys to delete on).
- The 3 `doc_id`-only entries (Jónsson-Tarski I/II, Goldblatt) and the 2 unpaired `path`-adjacent
  populated entries (`pym_ohearn_yang_2004_...`, `ishtiaq_ohearn_2001_...`) are explicitly out of
  scope and must not be touched by this task's implementation.
- Post-deletion acceptance should check: (a) total entries == 361, (b) `json.load` succeeds,
  (c) `literature-build-index.sh --global` exits 0, (d) `chunks_fts` row count >= 17,736 (the
  live baseline established in this report). Criterion (d) is expected to be trivially satisfied
  and unchanged (still 17,736) since the FTS build path is independent of `index.json`; treat any
  *decrease* as a signal that something else (an accidental chunk-file/manifest edit) went wrong,
  not as validation that the dedup itself succeeded.

## Risks & Mitigations

- **Risk**: An implementer might key deletion on array index or on `token_count == 0`, both of
  which are stale/fragile signals (token_count is now fixed on both sides; index ordering is
  incidental). **Mitigation**: key on `provenance` field presence (`"migrated from ingest schema
  (doc_id/source_path/chunks_dir)"`) combined with `id` match — this is the field the description
  itself flags and it was independently confirmed to be the exclusive discriminator on the stale
  side across all 8 pairs.
- **Risk**: Conflating the 8-pair cluster with the 3 unrelated `doc_id`-only entries at the tail
  of the array (also today's-dated ingest artifacts) could cause an over-broad deletion.
  **Mitigation**: explicitly scope the deletion loop to the 8 named ids only; do not generalize to
  "any entry with a `provenance`/`doc_id` ingest-schema shape."
- **Risk**: Misreading the FTS-row-count check as a meaningful pass/fail signal for whether the
  dedup itself worked. **Mitigation**: this report documents why it is not — rely on entry-count
  (369 -> 361) and JSON-parse success as the real outcome gates for the index.json edit itself;
  use the FTS check only as a side-effect-free-deletion sanity check.
- **Risk**: `~/Projects/Literature` working tree is already dirty (today's ingests plus this
  task's future edit), which could make a `git diff` review of the dedup change noisy.
  **Mitigation**: implementer should isolate the 8 deletions via `git diff -- index.json` scoped
  review, or stage/commit the pre-existing changes separately before making the dedup edit, if
  that workflow is desired (not this task's call to make unilaterally).

## Context Extension Recommendations

None. This is a one-off data-hygiene task on an external corpus (`~/Projects/Literature/`), not
a gap in `.claude/context/` documentation.

## Appendix

### Commands/queries used

```bash
python3 -c "import json; ... count entries/ids/duplicates in index.json"
python3 -c "... per-id, per-field comparison of the 8 duplicate pairs"
cat ~/Projects/Literature/.claude/scripts/literature-build-index.sh
bash ~/Projects/Literature/.claude/scripts/literature-build-index.sh --global
sqlite3 ~/Projects/Literature/.literature.db "SELECT count(*) FROM chunks_fts;"
sqlite3 ~/Projects/Literature/.literature.db "SELECT count(*) FROM chunks_data;"
sqlite3 ~/Projects/Literature/.literature.db "SELECT count(DISTINCT doc_id) FROM chunks_data;"
git -C ~/Projects/Literature status --porcelain index.json
git -C /home/benjamin/Projects/BimodalLogic status --porcelain specs/literature-index.json
```

### References

- `~/Projects/Literature/index.json`
- `~/Projects/Literature/.claude/scripts/literature-build-index.sh`
- `~/Projects/Literature/<doc-dir>/chunks.json` (8x, one per duplicated id)
- `specs/literature-index.json` (repo sub-index, read-only)

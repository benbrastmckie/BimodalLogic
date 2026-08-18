# Implementation Plan: Repair the remaining Literature corpus data defects

- **Task**: 457 - Repair the remaining Literature corpus data defects
- **Status**: [COMPLETED]
- **Effort**: 8.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/457_repair_remaining_literature_corpus_data_defects/reports/01_literature-corpus-data-repairs.md
- **Artifacts**: plans/01_corpus-data-repairs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This is a **data-only** repair pass over two literature indices: the global corpus index at
`~/Projects/Literature/index.json` (369 entries, corpus of record) and this repo's 45-entry
relevance sub-index at `specs/literature-index.json`. No agent-system code is written or changed
here; the five corresponding code defects live in the global agent-system repo and are explicitly
out of scope. The work is decomposed into one baseline phase, five sequential mutation batches
(each preceded by its own timestamped backup and followed by its own validate + FTS-rebuild
gate), and one closeout phase that records the deferral decisions and spawns the follow-up tasks.
Definition of done: all six repair scopes applied and re-validated, the deferred/out-of-scope
scopes recorded with explicit rationale, the FTS database rebuilt clean, and follow-up tasks
opened for the three items that are not data repairs.

### Research Integration

The research report re-verified all eight scopes against the live 369-entry index (independently
re-confirmed at plan time: 369 entries, `index.json` top-level shape
`{version, description, token_budget, max_chunks, entries}`). Findings carried into this plan:

- **SCOPE 1**: `diamondsareforever` is the only entry corpus-wide whose `path` matches
  `chunk_\d+\.md$`. Three sibling entries (`brast-mckie_2026_construction-possible-worlds`,
  `brast-mckie_2026_counterfactual-worlds`, `goldblatt_2023_strong-completeness-real-time`)
  establish the directory-path convention to follow. Recomputed token_count ≈ 21,755
  (`chars/4+20`) vs. 21,710 (sum of `chunks.json` per-chunk counts), against a stored 95,000.
- **SCOPE 2**: three stub token_counts recomputed as 26,772 / 11,716 / 15,958 — but the report's
  own instruction is to recompute **fresh at implementation time** rather than replay any cited
  figure.
- **SCOPE 3**: research's own recomputation finds **56** drifted entries excluding SCOPE 1/2 (the
  task said "roughly 52"); 44 in the 1.20–1.35 band; all drift in the same direction. New finding:
  all 12 `baier_katoen_2008_partNN` entries carry the identical stored `token_count` of 39848 —
  a copy-paste placeholder, not organic drift. Repair approach is unchanged by the count
  discrepancy: recompute and re-baseline every entry found drifting live.
- **SCOPE 4**: `literature-normalize-authors.sh` dry run proposes exactly 60 correct
  normalizations; zero array-valued entries carry a comma-joined element.
- **SCOPE 5**: the 35-entry figure is exact once the 15 legacy `chunks_dir`-only entries are
  excluded from the denominator; all 35 are missing **both** fields together, never just one.
- **SCOPE 6**: 22 both-schema and 37 absolute-`chunks_dir` counts confirmed; no consumer found
  that reads `chunks_dir` in preference to `path`. Research recommends deferral.
- **SCOPE 7**: all three entries confirmed legacy-schema with the fidelity narrative already
  present in `specs/literature-index.json`. Research recommends `unverified_conversion` for the
  Jönsson-Tarski pair and `verified_conversion` for Goldblatt 2006. Coverage gap: 12 further
  legacy-schema entries beyond the named 3.
- **SCOPE 8**: both acquisition gaps confirmed (Gabbay 2003 present in Zotero as `Kurucz2003`
  but absent from the corpus; Goldblatt 1989 absent from both; `goldblatt_2003` confirmed to be
  the distinct Erdős-graphs paper). Neither is a data repair.

### Planning Decisions

Three points the research report flagged for explicit planning adjudication are settled here:

1. **Token-count formula**: `chars/4 + 20` for every recomputation in every scope (SCOPE 1, 2, 3,
   7). One formula corpus-wide; no per-scope variants. Adopts research Decision 1.
2. **SCOPE 7 coverage gap (12 additional legacy-schema entries)**: adopt research option (b) —
   **spawn a dedicated follow-up task**, do not silently widen SCOPE 7 from 3 entries to 15.
   Handled in Phase 7.
3. **SCOPE 6**: **deferred**, not silently dropped. Phase 7 writes the deferral rationale into the
   task summary so the investigation does not have to be redone from scratch. No mutation.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context; roadmap consultation skipped.

## Goals & Non-Goals

**Goals**:
- Repair the `diamondsareforever` malformed `path` and its wrong whole-document `token_count`
  (SCOPE 1).
- Recompute the three stub-extract `token_count` values from disk (SCOPE 2).
- Re-baseline every drifted `token_count` corpus-wide, including the 12-entry
  `baier_katoen_2008` uniform-placeholder set (SCOPE 3).
- Normalize the 60 comma-joined `authors` strings to arrays (SCOPE 4).
- Fill `doc_type` and `source_format` on the 35 v2-schema entries missing both (SCOPE 5).
- Adjudicate and stamp `provenance_fidelity` for the three newly ingested documents, grounded in
  a fresh manual spot-check, and mirror the outcome consistently across both indices (SCOPE 7).
- Leave the corpus in a validated, FTS-rebuilt state after every mutation batch, with a restorable
  backup per batch.
- Record the SCOPE 6 deferral rationale and open follow-up tasks for SCOPE 8 and the 12-entry
  legacy-schema coverage gap.

**Non-Goals**:
- Any change to agent-system code (`.claude/**`, `agent-system/**`). The five corresponding code
  defects are tracked in the global agent-system repo and MUST NOT be duplicated here.
- Migrating the 15 legacy `chunks_dir`-only entries to the v2 schema beyond the 3 named in
  SCOPE 7.
- Normalizing the 22 both-schema entries or the 37 absolute `chunks_dir` values (SCOPE 6 —
  deferred).
- Acquiring, OCRing, or converting the two missing sources (SCOPE 8 — spawned as separate tasks).
- Re-converting any document. This pass edits index metadata only; it never rewrites source
  markdown.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A fidelity stamp written from an automated word ratio alone silently invalidates downstream Lean citations (documented precedent: the `rabinovich_2014` hazard field, 89 citations) | H | M | Phase 6 requires opening at least one chunk from each of the three documents by hand before any stamp is written; `literature-fidelity-audit.sh` output is corroboration only and is explicitly NOT the stamping authority. A phase that cannot complete the manual read blocks rather than stamps. |
| A partial/interrupted write corrupts `index.json` mid-batch (the file is rewritten wholesale by both the authors script and the bulk token rewrite) | H | L | One timestamped backup per mutation batch (not one for the whole task), taken immediately before the write; JSON-parse + entry-count check immediately after; rollback is a single file copy. |
| SCOPE 3's bulk re-baseline papers over a genuine content-corruption event (mojibake, duplicated content) rather than a metadata defect | H | L | Spot-read 2-3 of the drifted `.md` files for sane prose before the bulk write. The `baier_katoen_2008` uniform-placeholder finding and the 44-entry tight-ratio clustering are the affirmative evidence this is a metadata defect; the spot-check is the falsifier. |
| `path` and `token_count` changes (SCOPE 1, SCOPE 7) desynchronize the FTS database from the index | M | M | `literature-build-index.sh --global` is run as a hard gate at the end of every mutation phase, not once at the end of the task, and the resulting FTS row count is compared against the Phase 1 baseline. |
| Live corpus counts have drifted since research (the corpus is a moving target) | M | M | Phase 1 regenerates every worklist from the live index; no phase replays a frozen ID list from the report. Each phase carries a Scope Hypothesis naming the report's count and how to re-confirm it. |
| SCOPE 5's `source_format` is blanket-assumed `pdf` and is wrong for some entries | M | M | Phase 5 inspects each entry's source directory for the actual source file extension rather than assuming; entries with no source file on disk are recorded as exclusions with evidence, not guessed. |
| Scope creep from 3 to 15 legacy-schema entries in SCOPE 7 | M | M | Planning Decision 2 fixes SCOPE 7 at exactly the 3 named entries; the other 12 become a spawned task in Phase 7. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. This plan is **fully sequential by
construction**: phases 2-6 all rewrite the same `~/Projects/Literature/index.json` wholesale, so
no two of them may run concurrently regardless of scope independence. Do not parallelize them.

---

### Phase 1: Baseline, safety harness, and live worklist generation [COMPLETED]

**Goal**: Establish the pre-repair baseline (entry count, validation state, FTS row count),
confirm every tool this plan depends on is present and behaves as research described, and
regenerate every scope's worklist from the **live** index so no later phase replays a stale ID
list. No mutation of either index.

**Tasks**:
- [x] Confirm prerequisites: `python3`, `jq`, `sqlite3` present; `.claude/scripts/literature-normalize-authors.sh`, `literature-build-index.sh`, `literature-fidelity-audit.sh` present and executable *(completed)*
- [x] Create the working directory `specs/457_repair_remaining_literature_corpus_data_defects/data/` *(completed)*
- [x] Record baseline: entry count of `~/Projects/Literature/index.json` (expected 369), JSON parses clean, top-level keys `version/description/token_budget/max_chunks/entries` *(completed)*
- [x] Record baseline FTS row count from `~/Projects/Literature/.literature.db` and a sample `literature-search.sh` query returning hits, so post-rebuild comparisons have a floor *(completed)*
- [x] Take the master pre-task backup: `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-457` (this is the task-level rollback point, in addition to the per-batch backups later phases take) *(completed)*
- [x] Back up `specs/literature-index.json` the same way *(completed)*
- [x] Generate `data/scope1-2.tsv`: the entry whose `path` matches `chunk_\d+\.md$`, plus the three named stub entries, each with stored vs. freshly recomputed `chars/4+20` token_count *(completed)*
- [x] Generate `data/scope3-drift.tsv`: every entry carrying `path` whose stored `token_count` diverges from `chars/4+20` by more than 20%, excluding the four entries in `data/scope1-2.tsv`; record the live count and whether the 12 `baier_katoen_2008_partNN` entries still share one stored value *(completed)*
- [x] Generate `data/scope4-authors.txt`: output of `bash .claude/scripts/literature-normalize-authors.sh ~/Projects/Literature/index.json` (bare = dry run), and record the "Entries that would change" count *(completed)*
- [x] Generate `data/scope5-missing-fields.tsv`: entries missing `doc_type` and/or `source_format`, with a column marking which are legacy `chunks_dir`-only entries so the two populations stay separated; for each non-legacy entry also record the actual source-file extension(s) found in its source directory *(completed)*
- [x] Generate `data/scope6-schema.tsv`: entries carrying both `path` and `chunks_dir`, and entries with an absolute `chunks_dir` (for the Phase 7 deferral record only) *(completed)*
- [x] Generate `data/scope7-legacy.tsv`: all legacy `chunks_dir`-only entries, marking the 3 named in SCOPE 7 and the remainder *(completed)*
- [x] Write `data/baseline.md` recording every count above alongside the report's stated count, with a PASS/DRIFTED verdict per scope *(completed)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The report asserts 369 entries; 1 chunk-path entry; 3 stubs; 56 drifted
(report) vs. "roughly 52" (task); 60 author normalizations; 35 missing-field entries (50 before
excluding 15 legacy); 22 both-schema; 37 absolute `chunks_dir`; 15 legacy entries of which 3 are
named. Confirm every one of these against the live index in this phase and record the live number
in `data/baseline.md`. **Later phases consume the live numbers, never the report's.** A divergence
of more than ±10% on any count is a signal to stop and re-read the corpus, not to proceed with the
live number silently.

**Files to modify**:
- `specs/457_repair_remaining_literature_corpus_data_defects/data/*` - new working files (created)
- `~/Projects/Literature/index.json.bak-*-pre-457` - new backup (created; original untouched)
- `specs/literature-index.json.bak-*-pre-457` - new backup (created; original untouched)

**Verification**:
- `~/Projects/Literature/index.json` byte-identical to its state at phase start (`cmp` against the master backup returns 0 differences)
- `specs/literature-index.json` likewise unchanged
- All seven `data/*.tsv` worklists exist and are non-empty
- `data/baseline.md` records a live count for every scope with an explicit PASS/DRIFTED verdict

---

### Phase 2: SCOPE 1 + SCOPE 2 — diamondsareforever path/token fix and three stub token counts [COMPLETED]

**Goal**: Repair the four entries with a single unambiguous target value each: point
`diamondsareforever`'s `path` at its directory (matching the 3-sibling convention) and correct
its token_count, and replace the three stub-extract token_counts with values recomputed from disk.

**Tasks**:
- [x] Back up: `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-scope12` *(completed)*
- [x] Re-confirm from disk that `sources/diamondsareforever/` contains only `chunk_NNNN.md` files and no canonical whole-document `.md` (if a canonical file has appeared since research, use it as the token_count source instead and record the deviation) *(completed)*
- [x] Set `diamondsareforever.path` to `"sources/diamondsareforever/"`, matching the trailing-slash form used by the sibling directory-path entries *(completed)*
- [x] Set `diamondsareforever.token_count` to the `chars/4+20` value over the concatenated chunk text (research computed 21,755; recompute fresh — do not paste the figure) *(completed)*
- [x] Recompute and write `token_count` for `fine_2012_guide-to-ground`, `vardi_wolper_1986_automata_verification`, and `fine_2012_counterfactuals-without-possible-worlds` from the canonical `.md` in each directory, excluding `chunk_*.md` re-splits per `chunk-file-conventions.md` *(completed)*
- [x] Run the post-mutation gate (below) *(completed)*
- [x] Commit the `specs/` side of this batch (worklists, notes); the global index lives outside this repo and is protected by its backup, not by a commit *(completed)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly 4 entries change. Confirm by diffing the mutated index against the
`pre-scope12` backup and counting changed entries — if the count is not 4, stop and reconcile
before proceeding.

**Files to modify**:
- `~/Projects/Literature/index.json` - `path` on 1 entry, `token_count` on 4 entries
- `~/Projects/Literature/index.json.bak-*-pre-scope12` - new backup (created)

**Verification**:
- `python3 -c "import json; json.load(open('index.json'))"` exits 0
- Entry count still matches the Phase 1 baseline (369 unless Phase 1 recorded otherwise)
- Diff against the `pre-scope12` backup touches exactly 4 entries and only the fields named above
- No entry corpus-wide has a `path` matching `chunk_\d+\.md$` any more (the SCOPE 1 defect class is empty)
- `bash .claude/scripts/literature-build-index.sh --global` exits 0
- Post-rebuild FTS row count is greater than or equal to the Phase 1 baseline; a sample search query still returns hits
- All four repaired `token_count` values are within ±20% of a fresh `chars/4+20` recomputation

---

### Phase 3: SCOPE 3 — bulk token_count re-baseline [COMPLETED]

**Goal**: Overwrite the stored `token_count` with a freshly recomputed `chars/4+20` value for
every `path`-carrying entry whose stored value diverges by more than 20%, including the 12
`baier_katoen_2008_partNN` entries sharing one placeholder value.

**Tasks**:
- [x] Regenerate `data/scope3-drift.tsv` against the current (post-Phase-2) index — the Phase 1 copy is now one mutation stale *(completed)*
- [x] **Falsifier check before writing**: open 2-3 of the drifted `.md` files and read a page of each, confirming sane expected prose (not mojibake, not duplicated content). If any file reads as corrupted, stop: the defect is content corruption, not metadata drift, and this phase's premise is wrong *(completed)*
- [x] Confirm the `baier_katoen_2008` uniform-placeholder finding still holds (all 12 sharing one stored value) and record the recomputed per-part spread *(completed)*
- [x] Back up: `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-scope3` *(completed)*
- [x] Apply the bulk `token_count` rewrite to every entry on the regenerated worklist *(completed: regenerated worklist (84) + full baier_katoen 12-set + 8 duplicate-id stale placeholders found invisible to id-keyed lookup (96 total field changes))*
- [x] Run the post-mutation gate (below) *(completed)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The report's recomputation found 56 drifted entries excluding SCOPE 1/2
(44 in the 1.20–1.35 band); the task description said "roughly 52". The live number is whatever
the regenerated `data/scope3-drift.tsv` reports — treat 52-56 as the expected range, record the
actual, and flag anything outside it in the phase notes. The 12-entry `baier_katoen_2008`
uniform-value sub-finding is a separate hypothesis: confirm all 12 still share one stored value
before treating it as a placeholder bug.

**Files to modify**:
- `~/Projects/Literature/index.json` - `token_count` on ~52-56 entries
- `~/Projects/Literature/index.json.bak-*-pre-scope3` - new backup (created)
- `specs/457_repair_remaining_literature_corpus_data_defects/data/scope3-drift.tsv` - regenerated

**Verification**:
- JSON parses; entry count unchanged against baseline
- Diff against `pre-scope3` backup touches only `token_count` fields, on the exact entry set in the regenerated worklist — no other field and no other entry
- Re-running the `chars/4+20` comparison corpus-wide now finds **zero** `path`-carrying entries drifting past 20% (the defect class is empty)
- The 12 `baier_katoen_2008_partNN` entries now carry 12 distinct values
- `bash .claude/scripts/literature-build-index.sh --global` exits 0; FTS row count >= baseline
- The 2-3 spot-read files are named in the phase notes with a one-line prose verdict each

---

### Phase 4: SCOPE 4 — authors field normalization [COMPLETED]

**Goal**: Convert the comma-joined `authors` strings to arrays using the existing script, and
confirm the malformed-array regression the script also guards against has not reappeared.

**Tasks**:
- [x] Re-run the dry run against the current index and confirm the proposed change count and that sampled before/after pairs are correct splits *(completed)*
- [x] Back up: `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-scope4` *(completed)*
- [x] Run `bash .claude/scripts/literature-normalize-authors.sh ~/Projects/Literature/index.json --apply` *(completed: 60 converted; 5 (hughes_1996 group) manually corrected for a two-author single-element mis-split)*
- [x] Run the script bare again to confirm idempotence (zero proposed changes on the second pass) *(completed)*
- [x] Run the post-mutation gate (below) *(completed)*

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The report's dry run proposed exactly 60 normalizations and found zero
array-valued entries containing a comma-joined element. Re-confirm both numbers against the live
index in this phase before applying; a materially different count means the corpus changed and
the sampled before/after pairs must be re-inspected.

**Files to modify**:
- `~/Projects/Literature/index.json` - `authors` on ~60 entries
- `~/Projects/Literature/index.json.bak-*-pre-scope4` - new backup (created)

**Verification**:
- JSON parses; entry count unchanged against baseline
- Second bare invocation of the script reports zero entries would change (idempotent)
- Zero entries corpus-wide have a string-valued `authors`
- Zero array-valued `authors` entries contain an element with an embedded `", "` join
- Diff against `pre-scope4` backup touches only `authors` fields
- `bash .claude/scripts/literature-build-index.sh --global` exits 0; FTS row count >= baseline

---

### Phase 5: SCOPE 5 — fill doc_type and source_format on the 35 v2-schema entries [COMPLETED]

**Goal**: Populate the two missing required v2 fields on every v2-schema entry that lacks them,
with `source_format` grounded in the actual source file on disk rather than a blanket assumption,
and with the 15 legacy `chunks_dir`-only entries deliberately excluded from the population.

**Tasks**:
- [x] Regenerate `data/scope5-missing-fields.tsv` against the current index, keeping the legacy-entry marker column *(completed)*
- [x] Confirm the legacy entries are excluded from the working set and that every remaining entry is missing **both** fields (not just one) — a single-field-missing entry is outside the pattern research described and needs individual inspection *(completed)*
- [x] For each entry, determine `source_format` by inspecting its source directory for the actual source file extension (`.pdf`, `.djvu`, etc.). Where no source file exists on disk, record the entry as an exclusion with evidence rather than guessing *(completed)*
- [x] For each entry, infer `doc_type` (book / paper / article) from title and venue context, using the values already in use elsewhere in the corpus rather than inventing new ones *(completed)*
- [x] Back up: `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-scope5` *(completed)*
- [x] Write both fields for every non-excluded entry *(completed)*
- [x] Record any exclusions in a `#### Reasoned Exclusions` subsection under this phase, per plan-format.md *(completed)*
- [x] Run the post-mutation gate (below) *(completed)*

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The report asserts exactly 35 entries once the 15 legacy `chunks_dir`-only
entries are excluded from a naive count of 50, and that all 35 are missing both fields together.
Re-derive all three numbers (naive count, legacy count, difference) from the live index and
confirm the both-fields-together property holds for every entry before writing. The report's
further assertion that `source_format` is "almost certainly `pdf` for all of these" is a
hypothesis to test per entry against the source directory, not a value to apply in bulk.

**Files to modify**:
- `~/Projects/Literature/index.json` - `doc_type` and `source_format` on ~35 entries
- `~/Projects/Literature/index.json.bak-*-pre-scope5` - new backup (created)
- `specs/457_repair_remaining_literature_corpus_data_defects/data/scope5-missing-fields.tsv` - regenerated

**Verification**:
- JSON parses; entry count unchanged against baseline
- Every non-legacy entry corpus-wide now carries both `doc_type` and `source_format`, except entries recorded in the Reasoned Exclusions table
- Every written `source_format` value corresponds to a source file actually found on disk, or is an entry in the exclusions table
- Every written `doc_type` value is drawn from the set already in use elsewhere in the corpus
- The 15 legacy `chunks_dir`-only entries are untouched by this phase's diff
- Diff against `pre-scope5` backup touches only `doc_type` and `source_format` fields
- `bash .claude/scripts/literature-build-index.sh --global` exits 0; FTS row count >= baseline

#### Reasoned Exclusions

29 of the 35 entries were filled with both `doc_type` and `source_format`: 26 by inheriting from
an already-populated `parent_doc` entry (7 `church_1956_ch*`, 5 `gentzen_1935_sec*`, 4
`hughes_1996_p*`, 6 `mendelson_2016_ch*`, 4 `zakharyaschev_2001_sec*`), plus `gabbay_1994_ch10`
(source evidenced in its sibling `gabbay_1994/` directory), `proofs_and_types`, and
`van_doorn_2015_propositional_calculus_coq` (both found a `.pdf` directly in their own source
directory). The remaining 6 entries below have `doc_type` filled (inferred from title/summary,
using the corpus's existing `paper` category) but `source_format` deliberately left absent —
no source file was found on disk, no `parent_doc` field to inherit from, and no
`zotero_key`/`zotero_path` to cross-reference, so `source_format` is recorded here as an
exclusion rather than guessed.

| Item | Reason | Evidence |
|------|--------|----------|
| `bentzen_2023` | No source file, no parent, no Zotero link | `sources/bentzen_2023/` contains only `bentzen_2023.md` + `chunk_*.md`/`chunks.json`; `zotero_key`/`zotero_path` both null |
| `from_2022` | No source file, no parent, no Zotero link | `sources/from_2022/` contains only `from_2022.md` + `chunk_*.md`/`chunks.json`; `zotero_key`/`zotero_path` both null |
| `henkin_1949` | No source file, no parent, no Zotero link | `sources/henkin_1949/` contains only `henkin_1949.md` + `chunk_*.md`/`chunks.json`; `zotero_key`/`zotero_path` both null |
| `johansson_1937` | No source file, no parent, no Zotero link | `sources/johansson_1937/` contains only `johansson_1937.md` + `chunk_*.md`/`chunks.json`; `zotero_key`/`zotero_path` both null |
| `post_1921` | No source file, no parent, no Zotero link | `sources/post_1921/` contains only `post_1921.md` + `chunk_*.md`/`chunks.json`; `zotero_key`/`zotero_path` both null |
| `trufas_2024` | No source file, no parent, no Zotero link | `sources/trufas_2024/` contains only `trufas_2024.md` + `chunk_*.md`/`chunks.json`; `zotero_key`/`zotero_path` both null |

---

### Phase 6: SCOPE 7 — provenance adjudication for the three newly ingested documents [COMPLETED]

**Goal**: Stamp `provenance_fidelity` on the Jönsson-Tarski 1951/1952 pair and Goldblatt 2006,
populate their `path` and `token_count` following the SCOPE 1 directory-path convention, and keep
the sub-index's degraded-formula warning intact and consistent with the stamp. The stamp is
written only after a fresh manual read, never from an automated ratio.

**Tasks**:
- [x] **Manual spot-check gate (hard precondition)**: open at least one chunk from each of the
      three documents and read it. For the Jönsson-Tarski pair, confirm the degraded-formula
      symptoms the sub-index describes are actually present. For Goldblatt 2006, confirm prose and
      symbols read cleanly. Record the chunk filename and a one-line verdict for each of the three.
      **If any of the three cannot be read and judged, this phase BLOCKS — it does not stamp.**
      *(completed: J-T 1951 chunk_0020.md — prose coherent, formulas degraded, confirmed. J-T
      1952 chunk_0040.md — same symptom confirmed. Goldblatt chunk_0050.md + chunk_0100.md —
      prose and symbols both clean, confirmed. Full verdicts in progress/phase-6-progress.json)*
- [x] Run `bash .claude/scripts/literature-fidelity-audit.sh --dry-run` and record its
      classification for the three documents as **corroboration only**. A disagreement between the
      audit and the manual read is resolved in favour of the manual read, and the disagreement is
      recorded in the phase notes *(completed: audit does not cover these 3 (online-ingest-bridge entries fall outside its sources/-only scan scope) -- no corroboration available, manual read is sole evidence, per plan design)*
- [x] Confirm the on-disk chunk counts still match the index (research: 85 / 82 / 199) *(completed)*
- [x] Back up **both** indices: `index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-scope7` and the matching backup of `specs/literature-index.json` *(completed)*
- [x] Set `provenance_fidelity` to `unverified_conversion` on Jönsson-Tarski I and II — deliberately **not** `verified_conversion`, which would read as a blanket green light covering formulas *(completed)*
- [x] Set `provenance_fidelity` to `verified_conversion` on Goldblatt 2006 *(completed)*
- [x] Populate `path` for all three, pointing at the source directory per the SCOPE 1 convention *(completed)*
- [x] Populate `token_count` for all three using `chars/4+20` over the canonical `.md` if one exists, else over the chunk files *(completed)*
- [x] Verify the sub-index `fidelity` narrative for all three is intact and not paraphrased away or weakened by the stamp; in particular the "Do NOT transcribe any equation, axiom, or symbolic statement into Lean from the markdown alone" warning must survive verbatim *(completed)*
- [x] Run the post-mutation gate (below) *(completed)*

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Exactly 3 entries change in the global index, and the sub-index changes only
if a consistency fix is required (the expected outcome is that its narrative is already correct
and needs no edit). The report asserts chunk counts of 85 / 82 / 199 and that all three sit in the
legacy `chunks_dir` schema with `provenance_fidelity` and `token_count` absent — confirm all of
this live before writing. The recommended enum values are a research judgment call, not a derived
fact: the manual spot-check is what confirms or overturns them.

**Commit-mode note**: `atomic-batch` because the global-index stamp and the sub-index consistency
state are one semantic unit — a corpus stamped `verified_conversion` while the sub-index warning
says otherwise is precisely the inconsistency that produced the `rabinovich_2014` hazard. Do not
commit an intermediate state where only one of the two has been updated.

**Files to modify**:
- `~/Projects/Literature/index.json` - `provenance_fidelity`, `path`, `token_count` on 3 entries
- `specs/literature-index.json` - fidelity-narrative consistency check; edit only if inconsistent
- `~/Projects/Literature/index.json.bak-*-pre-scope7` - new backup (created)
- `specs/literature-index.json.bak-*-pre-scope7` - new backup (created)

**Verification**:
- Both files parse as JSON; global entry count unchanged against baseline
- All three entries carry a non-null `provenance_fidelity` drawn from the existing corpus enum (`verified_conversion`, `no_source_pdf`, `unverified_no_baseline`, `unadjudicated`, `not_yet_converted`, `unverified_conversion`) — no new enum value invented
- The phase notes name one chunk file per document plus a one-line manual verdict for each; a phase completing without these three records is not complete
- The sub-index degraded-formula warning for the Jönsson-Tarski pair is present and verbatim
- The other 12 legacy `chunks_dir`-only entries are untouched
- `bash .claude/scripts/literature-build-index.sh --global` exits 0; FTS row count >= baseline
- A `literature-search.sh` query targeting one of the three documents returns hits

**Phase notes — new code-level finding (not fixed here, out of scope)**: `literature-search.sh`'s
`load_fidelity_map()` hard-codes an assumption that any `provenance_fidelity`-bearing entry has a
`path` starting with the literal prefix `sources/`. The three SCOPE 7 entries' real `chunks_dir`
lives directly under `LITERATURE_DIR` (the legacy online-ingest bridge location, not `sources/`),
so their honestly-populated `path` does not start with `sources/` and `load_fidelity_map()`
silently skips them, fail-opening `get_fidelity()` to `unverified_summary` for all three —
including Goldblatt 2006, which is genuinely `verified_conversion` and should not be quarantined
from default search ranking. `literature-search.sh --include-unverified` does return hits for all
three (satisfying the verification bullet above), but a default-mode query does not surface them
and misreports their fidelity. This is a CODE defect matching the pattern of the five already-
known code defects the plan's Overview places out of scope in the global agent-system repo — it
is recorded here, not fixed, since a fix would require either moving physical source directories
under `sources/` (a filesystem reorganization beyond this plan's "edits index metadata only"
Non-Goal) or editing `literature-search.sh` (agent-system code, explicitly out of scope). See
`progress/phase-6-progress.json`'s `new_code_level_finding` for the full writeup.

---

### Phase 7: Closeout — SCOPE 6 deferral record, SCOPE 8 and coverage-gap follow-ups, final corpus validation [COMPLETED]

**Goal**: Record the deferral decisions with enough evidence that the investigation need not be
redone, open the follow-up tasks for the three items that are not data repairs, and run the final
whole-corpus validation and FTS rebuild.

**Tasks**:
- [x] Write the SCOPE 6 deferral record into the task summary: the live both-schema and
      absolute-`chunks_dir` counts, the finding that no consumer in `.claude/scripts/literature-*.sh`
      reads `chunks_dir` in preference to `path`, and the conclusion that this is legacy residue
      rather than active breakage. Note that absolute-path normalization is a portability
      nice-to-have, not a correctness fix *(completed: live post-repair counts: 25 both-schema (up from 22 pre-repair, +3 from Phase 6's SCOPE7 path additions), 37 absolute chunks_dir (unchanged). Full record in the summary.)*
- [x] Spawn a follow-up task for the 12 legacy `chunks_dir`-only entries beyond SCOPE 7's named 3,
      naming them explicitly and pointing at Phase 6's adjudication process as the template *(completed: task 458 (migrate_12_legacy_literature_entries_to_v2_schema))*
- [x] Spawn a follow-up task for the Gabbay/Kurucz/Wolter/Zakharyaschev 2003 acquisition gap,
      recording that the source is present in Zotero as `Kurucz2003` and that the blocker is broken
      PDF font encoding — an OCR/acquisition problem, not an index-schema one *(completed: task 460 (acquire_gabbay_2003_many_dimensional_modal_logics))*
- [x] Spawn a follow-up task for the Goldblatt 1989 "Varieties of complex algebras" acquisition
      gap, recording that it is absent from both the corpus and the 200-item Zotero library, and
      that `goldblatt_2003` in the corpus is the distinct Erdős-graphs paper *(completed: task 461 (acquire_goldblatt_1989_varieties_of_complex_algebras). Also spawned an unplanned 4th follow-up, task 459 (deduplicate_8_stale_literature_entries), for the duplicate-id defect discovered during Phase 3 -- see Phase 3 phase notes.)*
- [x] Run the final whole-corpus validation: JSON parse, entry count against the Phase 1 baseline,
      zero `chunk_\d+\.md$` paths, zero string-valued `authors`, zero non-legacy entries missing
      `doc_type`/`source_format`, zero `path`-carrying entries drifting past 20% on `chars/4+20`
      *(completed: all six checks pass — 369 entries, 0 chunk-paths, 0 string-authors, 6/6
      doc_type+source_format gaps are reasoned exclusions, 0 entries drifting past 20%)*
- [x] Run `bash .claude/scripts/literature-build-index.sh --global` one final time and confirm the
      FTS row count against the Phase 1 baseline *(completed)*
- [x] Confirm every per-batch backup file is present and readable (`pre-457`, `pre-scope12`,
      `pre-scope3`, `pre-scope4`, `pre-scope5`, `pre-scope7`) *(completed)*
- [x] Confirm no file under `.claude/**` or `agent-system/**` was modified by this task *(completed)*

**Timing**: 1.25 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The report asserts 22 both-schema entries and 37 absolute-`chunks_dir`
entries for the SCOPE 6 record, and 12 unnamed legacy entries beyond SCOPE 7's 3. Re-derive all
three counts from the post-repair index (they may have shifted slightly as a side effect of
Phase 6 populating `path` on three entries) and record the post-repair number in the deferral
record, not the pre-repair one.

**Files to modify**:
- `specs/457_repair_remaining_literature_corpus_data_defects/summaries/01_corpus-data-repairs-summary.md` - created (deferral record and closeout)
- `specs/TODO.md`, `specs/state.json` - via the spawn workflow, for the three follow-up tasks

**Verification**:
- All six defect classes (SCOPE 1-5, 7) verify empty or repaired against the live index
- Three follow-up tasks exist and are discoverable in `specs/TODO.md`
- The SCOPE 6 deferral record names live post-repair counts, not report-time counts
- Final `literature-build-index.sh --global` exits 0; FTS row count >= Phase 1 baseline
- `git status` shows no modification under `.claude/**` or `agent-system/**`
- All six backup files present and JSON-parseable

---

## Testing & Validation

Every mutation phase (2-6) runs this same gate before it may be marked complete. It is a
**per-batch** gate, not an end-of-task gate — a single scope's mistake must not be buried under
five other scopes' changes before it is caught.

- [x] A timestamped backup of the index being edited exists, taken immediately before the write
- [x] `python3 -c "import json; json.load(open(<index>))"` exits 0
- [x] Entry count matches the Phase 1 baseline (369 unless Phase 1 recorded otherwise)
- [x] The diff against the phase's own backup touches only the fields and only the entries the
      phase declared — no collateral edits
- [x] The phase's defect class verifies empty afterward (e.g. after Phase 4, zero string-valued
      `authors` remain corpus-wide)
- [x] `bash .claude/scripts/literature-build-index.sh --global` exits 0
- [x] Post-rebuild FTS row count is greater than or equal to the Phase 1 baseline; a sample
      `literature-search.sh` query still returns hits
- [x] No file under `.claude/**` or `agent-system/**` was modified

Additional whole-task validation, run in Phase 7:

- [x] All six defect classes verify empty or repaired simultaneously against one final index read
- [x] `literature-normalize-authors.sh` bare invocation reports zero proposed changes
- [x] Every `provenance_fidelity` value written in Phase 6 is backed by a named chunk file and a
      recorded manual verdict

## Artifacts & Outputs

- `specs/457_repair_remaining_literature_corpus_data_defects/plans/01_corpus-data-repairs.md` (this plan)
- `specs/457_repair_remaining_literature_corpus_data_defects/data/baseline.md` — pre-repair baseline counts, report-count comparison, PASS/DRIFTED verdicts
- `specs/457_repair_remaining_literature_corpus_data_defects/data/scope{1-2,3,4,5,6,7}*.tsv` — live worklists
- `specs/457_repair_remaining_literature_corpus_data_defects/summaries/01_corpus-data-repairs-summary.md` — execution summary including the SCOPE 6 deferral record
- `~/Projects/Literature/index.json` — repaired (SCOPE 1, 2, 3, 4, 5, 7)
- `~/Projects/Literature/index.json.bak-*-pre-{457,scope12,scope3,scope4,scope5,scope7}` — six rollback points
- `specs/literature-index.json` — consistency-verified against the Phase 6 stamps (edited only if inconsistent)
- `~/Projects/Literature/.literature.db` — rebuilt after each mutation batch
- Three spawned follow-up tasks: the 12 legacy-schema entries, the Gabbay 2003 acquisition gap, the Goldblatt 1989 acquisition gap

## Rollback/Contingency

Rollback granularity is one mutation batch. To revert phase N, copy its `pre-scopeN` backup back
over `~/Projects/Literature/index.json` and re-run `literature-build-index.sh --global`. Because
each backup is taken immediately before its own batch's write, restoring one backup discards
exactly that batch's changes and preserves every earlier batch's.

To revert the whole task, restore `index.json.bak-*-pre-457` and the matching
`specs/literature-index.json` backup, then rebuild the FTS index. The `specs/` side is
additionally recoverable through git; the global corpus at `~/Projects/Literature/` is not in this
repository, which is exactly why the per-batch backup discipline is non-optional rather than a
belt-and-braces convenience.

If Phase 6's manual spot-check cannot be completed, that phase blocks rather than stamping —
leaving `provenance_fidelity` absent is a correct, honest state; a wrong stamp is not. The
`rabinovich_2014` precedent (a falsely-stamped `verified_conversion` silently invalidating 89 Lean
citations) is the reason this contingency resolves toward blocking rather than toward a
best-effort guess.

# Implementation Plan: Task #458

- **Task**: 458 - Migrate the 12 remaining legacy `chunks_dir`-only literature entries to the v2 schema
- **Status**: [IMPLEMENTING]
- **Effort**: 5.75 hours
- **Dependencies**: Task 457 (SCOPE 7 precedent, completed)
- **Research Inputs**: `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/reports/01_legacy-entries-v2-migration.md`
- **Artifacts**: plans/01_migrate-12-legacy-entries.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Twelve legacy `chunks_dir`-only entries in `~/Projects/Literature/index.json` carry a thin 2026-08-05
ingest schema and are missing exactly five v2 fields: `provenance_fidelity`, `path`, `token_count`,
`doc_type`, `source_format`. This plan adds those five fields to each of the twelve — and nothing
else — following the narrow 5-field partial-migration template task 457's Phase 6 established for
the three SCOPE 7 entries. The defining constraint is that `provenance_fidelity` may be stamped
**only after a hand read of at least one chunk per document**: `literature-fidelity-audit.sh` is
`sources/`-scoped and structurally cannot corroborate any of these twelve, so the manual read is the
sole adjudication evidence. Definition of done: all twelve entries carry the five fields with
per-entry recorded evidence, every excluded `source_format` has a reasoned-exclusion record, and a
`literature-build-index.sh --global` rebuild leaves the FTS row count at or above a **freshly
re-derived** baseline.

### Research Integration

The research report (`reports/01_legacy-entries-v2-migration.md`) supplies the grounding this plan
is built on, and four of its findings shape the phase structure directly:

1. **The Phase 6 template is exactly reusable.** `data/phase6_mutate.py` in task 457 reads
   `chunks_dir`, globs `chunk_*.md`, computes `token_count = int(chars/4 + 20)`, sets
   `path = "{id}/"` (relative to `$LITERATURE_DIR`, **no `sources/` prefix**, trailing slash), and
   takes `provenance_fidelity` from a hand-populated `TARGETS` dict — never computed. All twelve
   targets need the identical treatment. Unlike the SCOPE 7 three, the twelve already carry an `id`
   field, so no `id` backfill and no `.id or .doc_id` lookup fallback is needed.
2. **The FTS gate is real but weak on the mutation axis.** `literature-build-index.sh` reads
   `chunks.json` manifests directly from disk and never reads `index.json`, so these five field edits
   cannot change the row count. The gate's genuine value is catching an accidental directory move or
   deletion. It is retained for exactly that reason, and Phase 6 states so explicitly rather than
   presenting a trivially-passing check as strong evidence.
3. **The twelve are not uniform in fidelity.** Ten sampled clean; `rutten-2000-universal-coalgebra`
   (header bleed, "mnning"/"detenninistic", garbled notation) and `reynolds-2003-ockhamist`
   (systematic dropped-`c` affecting ordinary prose and the paper's own title) show real OCR
   degradation. That split is why adjudication is two phases, not one: the ten clean entries are a
   throughput problem, the two degraded ones are a judgment problem.
4. **Two of twelve have a locatable source PDF via Zotero.** `rutten-2000-universal-coalgebra` and
   `rumberg-zanardo-2019-transition-structures` have real PDFs under `~/Documents/Zotero/storage/`;
   `thomason-1970-indeterminist-time` has a bibliographic record but no stored PDF; the remaining
   nine have neither. The research explicitly declined to decide whether Zotero counts as "the
   actual source file" — Planning Decision 1 below decides it.

**Plan-time drift already observed**: the research recorded 370 index entries and 17,788 FTS rows.
At plan time `~/Projects/Literature/index.json` holds **369** entries, and exactly **12** entries have
a null `doc_type` (the twelve targets). The corpus moved between research and planning, which is the
concrete reason Phase 1 re-derives every baseline live and no later phase replays a frozen number.

### Prior Plan Reference

No prior plan exists for task 458. The reference plan is task 457's
`specs/457_repair_remaining_literature_corpus_data_defects/plans/01_corpus-data-repairs.md`, from
which this plan borrows the shape (baseline phase, hard manual-read precondition, backup-before-
mutate, post-mutation FTS gate, closeout phase) but not the content. Effort calibration comes from
457's Phase 6: 1.5 hours for three documents including the manual read. Twelve documents at the same
per-document cost, with two needing deeper reads, is the basis for this plan's 5.75-hour estimate.

### Roadmap Alignment

No `roadmap_path` was supplied and no `specs/ROADMAP.md` was consulted. No roadmap phases are
included.

## Planning Decisions

These are decisions this plan makes so the implementer does not re-litigate them mid-phase. Each was
surfaced but deliberately left open by the research report.

**Decision 1 — Zotero cross-referencing IS in scope as `source_format` evidence.** The task
description says "inspect the actual source file if present". For
`rutten-2000-universal-coalgebra` and `rumberg-zanardo-2019-transition-structures` the file *is*
present, merely not at the stale `/tmp/task54-lit/` `source_path`. Grounding `source_format: pdf` on
an inspected real PDF is strictly better evidence than a blanket exclusion. **Constraint**: the
implementer must open each located PDF and confirm author + title + year match the entry before using
it; a near-miss (as with the different Fong & Spivak book and the different Jacobs book the research
found) is not evidence and falls back to exclusion.

**Decision 2 — the Zotero PDF grounds `source_format` only, never `provenance_fidelity`.** The
Zotero copy is *not* the PDF that was chunked (chunking predates any Zotero linkage). Comparing chunk
text against it would be a re-conversion audit, which is out of scope. `provenance_fidelity` for all
twelve rests on the chunk read alone.

**Decision 3 — no new enum values may be invented, for any of the five fields.**
`provenance_fidelity` must come from the corpus's existing six values (`verified_conversion`,
`no_source_pdf`, `unverified_no_baseline`, `unadjudicated`, `not_yet_converted`,
`unverified_conversion`). `doc_type` must come from the corpus's existing vocabulary (`chapter`,
`paper`, `book`, `section`, `manuscript`, `survey`, `thesis` — note there is no `report` value, which
matters for the two BRICS technical reports). `source_format` must come from `pdf`, `djvu`, `latex`,
`html`. If no existing value fits, the implementer records the reasoning, selects the nearest, and
escalates the gap in the implementation summary rather than widening an enum inside a data-only task.

**Decision 4 — `title`/`authors`/`year` backfill is an explicit Non-Goal.** All twelve have a
placeholder `title` equal to the id string, empty `authors`, and null `year`; three of them have real
bibliographic data available in `zotero-library.json`. Backfilling is genuinely valuable and
genuinely out of this task's stated 5-field scope, exactly as Phase 6 left the same fields untouched.
It becomes a follow-up recorded in Phase 7, not silent scope creep.

**Decision 5 — the two known `sources/`-prefix code defects are referenced, not fixed.**
`literature-fidelity-audit.sh` is `sources/<dir>/`-scoped, and `literature-search.sh`'s
`load_fidelity_map()` hard-codes a `sources/` path prefix, so all twelve will read as
`unverified_summary` in default search ranking once correctly stamped. Both are pre-existing
agent-system code defects already documented in task 457's Phase 6 phase notes. This plan cites that
record; it does not re-diagnose or repair them.

**Decision 6 — the context-documentation addition is deferred, not performed.** The research
recommends a "Partial v2 Migration for `chunks_dir`-only Entries" subsection in
`.claude/context/project/literature/domain/literature-index.md`. This repository has no
`agent-system/` source store, so the correct edit target is ambiguous under
`.claude/rules/source-store-deploy-boundary.md`, and a hand-authored `.claude/**` file risks being
wiped by the next deploy. Phase 7 records this as a follow-up with the ambiguity named.

## Goals & Non-Goals

**Goals**:
- Populate `provenance_fidelity`, `path`, `token_count`, `doc_type`, `source_format` on all twelve
  named legacy entries in `~/Projects/Literature/index.json`.
- Ground every `provenance_fidelity` stamp in a recorded hand read of at least one chunk of that
  document, with the chunk filename and a one-line verdict preserved per entry.
- Ground every `doc_type` and `source_format` value (or its exclusion) in per-entry recorded evidence.
- Leave the FTS index and every other index entry demonstrably unharmed.

**Non-Goals**:
- Backfilling `title`, `authors`, or `year` on any of the twelve (Decision 4).
- Renaming `doc_id` to `id`, or removing `chunks_dir` / `source_path`. This is an additive 5-field
  migration, matching the Phase 6 precedent exactly.
- Re-converting, re-chunking, or rewriting any source markdown. This pass edits index metadata only.
- Fixing the `sources/`-prefix defects in `literature-fidelity-audit.sh` or `literature-search.sh`
  (Decision 5).
- Touching the 8-id duplicate-entry defect (task 459's scope) or any non-target entry.
- Editing `specs/literature-index.json`. None of the twelve appear in the sub-index (verified at plan
  time), so it must end the task byte-identical.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A fidelity stamp is written from the research report's sampling instead of the implementer's own read, making the "manual adjudication" nominal | H | M | Phases 2 and 3 carry the Phase 6 hard precondition verbatim: open at least one chunk per document and read it; record filename + verdict; **if a document cannot be read and judged, the phase BLOCKS, it does not stamp**. The research sampling is corroboration, never the stamping authority. |
| The twelve are stamped uniformly (all `verified_conversion` or all `unverified_conversion`) despite the documented clean/degraded spread | H | M | Adjudication is split across two phases precisely so the two degraded entries get separate, deeper treatment; Phase 6 verification rejects a result in which all twelve share one value unless that uniformity is affirmatively defended per entry in the evidence file. |
| A partial or interrupted write corrupts `index.json` (the file is rewritten wholesale) | H | L | Timestamped backup immediately before the Phase 5 write, JSON-parse plus entry-count check immediately after; rollback is a single `cp`. A master pre-task backup is also taken in Phase 1. |
| A stale baseline (17,788 FTS rows / 370 entries from research) is used as the gate target | M | H (drift already observed: 369 entries at plan time) | Phase 1 re-derives entry count and FTS row count live and writes them to `data/baseline.md`; Phase 6 compares only against those, never against the report's numbers. |
| `reynolds-2003-ockhamist`'s prose-level letter-dropping does not map onto the existing six-value `provenance_fidelity` enum | M | M | Phase 3 makes the enum-adequacy judgment an explicit, recorded deliverable; Decision 3 forbids inventing a value and requires escalating the gap in the summary instead. |
| The mutation script silently touches fields or entries outside its remit | M | L | Phase 6 diffs the post-mutation index against the pre-mutation backup and asserts that the changed key set is exactly the five fields on exactly the twelve ids; the script itself is written to mutate only those keys. |
| `source_format` is blanket-excluded for all twelve, discarding the two real PDFs the research located | M | M | Decision 1 puts Zotero cross-reference in scope, with a same-work confirmation requirement; Phase 4 inspects both PDFs before writing `pdf`. |
| The FTS gate passes trivially and is mistaken for strong evidence that the mutation was correct | L | H (certain, given the code) | Phase 6 states the gate's limited meaning inline and pairs it with an independent token-count recomputation and a field-level diff, which are the checks that actually cover the mutation. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are genuinely parallelizable:
both are read-only over disjoint document sets and write to disjoint evidence files. Phase 5 is the
only phase that mutates `~/Projects/Literature/index.json`, so no mutation concurrency exists here at
all — unlike task 457's plan, which had to forbid parallelism across five mutating phases.

---

### Phase 1: Baseline, safety harness, and live re-derivation of the twelve [COMPLETED]

**Goal**: Establish a fresh, live pre-migration baseline (index entry count, FTS row count, per-entry
chunk counts, current field state), confirm every tool this plan depends on behaves as the research
described, and take the task-level rollback point. No mutation of any index.

**Tasks**:
- [x] Confirm prerequisites present and executable: `python3`, `jq`, `sqlite3`,
      `.claude/scripts/literature-build-index.sh`, `.claude/scripts/literature-search.sh`
- [x] Create the working directory `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/`
- [x] Record the live entry count and distinct-id count of `~/Projects/Literature/index.json`, and
      confirm it parses clean with top-level keys `version`/`description`/`token_budget`/
      `max_chunks`/`entries`. Use Python's `json` module, not `jq` regex matching over `.id` (the
      research hit a `null`-indexing error doing the latter)
- [x] Record the live FTS row count: `sqlite3 ~/Projects/Literature/.literature.db
      'SELECT count(*) FROM chunks_fts;'`. **This number, not 17,788 and not 17,736, is the Phase 6
      gate floor**
- [x] Confirm all twelve target ids are present exactly once each, and that each is missing exactly
      the five fields `provenance_fidelity`, `path`, `token_count`, `doc_type`, `source_format`
- [x] Confirm, for each of the twelve, that `chunks_dir` resolves to an existing directory directly
      under `~/Projects/Literature/<id>/` (not under `sources/`) and that its `chunk_*.md` count
      equals the stored `chunk_count`
- [x] Confirm no canonical whole-document `.md` exists in any of the twelve directories, which is
      what makes summing `chunk_*.md` the correct (not double-counting) `token_count` basis here
- [x] Confirm the twelve `/tmp/task54-lit/*.pdf` source files are still absent
- [x] Confirm `literature-fidelity-audit.sh` is `sources/`-scoped and produces no output for any of
      the twelve — record this as the reason the manual read is the sole evidence, matching the task
      description's premise
- [x] Take the master pre-task backup:
      `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-458`
- [x] Write `data/baseline.md` recording every live number above alongside the research report's
      stated number, with a PASS/DRIFTED verdict per item
- [x] Write `data/targets12.tsv` — one row per target id with `id`, `chunk_count`, `chunks_dir`,
      and empty columns for the adjudication values later phases fill in

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research asserts 370 index entries / 362 distinct ids and 17,788 FTS rows;
at plan time the index held 369 entries with exactly 12 null-`doc_type` entries, so the corpus has
already drifted twice. Confirm all of it live in this phase and record the live figures in
`data/baseline.md`; **every later phase consumes the live numbers, never the report's**. Also confirm
the report's per-entry chunk-count table (38 / 129 / 76 / 236 / 31 / 45 / 77 / 353 / 1448 / 32 / 29 /
41) against disk. A divergence beyond ±10% on the entry or FTS count, or any mismatch in the twelve's
chunk counts, is a signal to stop and re-read the corpus, not to proceed silently.

**Files to modify**:
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/baseline.md` - new (created)
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/targets12.tsv` - new (created)
- `~/Projects/Literature/index.json.bak-*-pre-458` - new backup (created; original untouched)

**Verification**:
- `~/Projects/Literature/index.json` is byte-identical to its phase-start state (`cmp` against the
  master backup reports no differences)
- `specs/literature-index.json` likewise unchanged
- `data/baseline.md` records a live entry count, a live FTS row count, and a PASS/DRIFTED verdict for
  every research assertion checked
- `data/targets12.tsv` has exactly 12 data rows and every `chunks_dir` in it exists on disk

---

### Phase 2: Manual fidelity adjudication — the ten entries that sampled clean [COMPLETED]

**Goal**: Reach and record a hand-read `provenance_fidelity` verdict for the ten entries the research
sampled as clean, and capture `doc_type` evidence from the same reads. Evidence-gathering only; no
index mutation occurs in this phase.

The ten: `brics-rs-96-35`, `brics-rs-94-7`, `cattani-winskel-2005-profunctors`,
`schultz-spivak-temporal-type-theory`, `fong-speranzon-spivak-temporal-landscapes`,
`schultz-spivak-vasilakopoulou-dynamical-systems-sheaves`, `thomason-1970-indeterminist-time`,
`jacobs-coalgebra-intro-draft`, `danos-krivine-rccs`, `rumberg-zanardo-2019-transition-structures`.

**Tasks**:
- [x] **Manual read gate (hard precondition)**: for each of the ten, open and read by hand at least
      two `chunk_*.md` files — one early content chunk (`chunk_0001.md` or `chunk_0002.md`;
      `chunk_0000.md` is 0 bytes for all twelve, an expected title-page artifact, and does not count)
      and one from the middle of the document. **If any document cannot be read and judged, this
      phase BLOCKS for that document — it does not stamp.**
- [x] For each, record in `data/adjudication.tsv`: `id`, the chunk filenames read, a one-line prose
      verdict in the implementer's own words, and the proposed `provenance_fidelity` value drawn from
      the existing corpus enum (Decision 3)
- [x] While reading, capture `doc_type` evidence from the document itself — a series line ("BRICS
      Report Series RS-96-35"), a running header, a preface, a journal masthead — and record it in a
      `doc_type_evidence` column. This is the cheapest place to get it, since the chunks are already
      open
- [x] Note explicitly where the implementer's verdict **disagrees** with the research report's
      sampling; the implementer's read wins, and the disagreement is recorded rather than smoothed
      over
- [x] Record for `jacobs-coalgebra-intro-draft` whether the repeated "FT" token the research observed
      is a watermark/footer artifact or genuine content corruption, since it is the one clean-sampled
      entry with a named anomaly
- [x] Write `progress/phase-2-progress.json` capturing the ten verdicts

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly ten entries and that all ten will read cleanly, per
the research sampling. Both halves are hypotheses. Confirm the count against `data/targets12.tsv`
(ten rows here plus two in Phase 3 must equal twelve with no overlap), and confirm the cleanliness
per document by the read itself — an entry that reads as degraded moves to a degraded verdict here
rather than being forced into a clean stamp to preserve the phase's framing.

**Files to modify**:
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/adjudication.tsv` - new (created);
  ten rows written here
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-2-progress.json` - new (created)

**Verification**:
- `data/adjudication.tsv` has ten rows, each naming at least two chunk filenames that exist on disk
- Every proposed `provenance_fidelity` value is one of the six values already present in the corpus
- Every row has a non-empty, document-specific verdict; a row whose verdict is generic boilerplate
  ("reads fine") is not complete
- `~/Projects/Literature/index.json` unchanged (`cmp` against the Phase 1 master backup)

---

### Phase 3: Manual fidelity adjudication — the two OCR-degraded entries [COMPLETED]

**Goal**: Reach a defensible, recorded `provenance_fidelity` verdict for
`rutten-2000-universal-coalgebra` and `reynolds-2003-ockhamist`, the two entries the research found
to carry real OCR degradation, and decide explicitly whether the existing enum can express the
`reynolds` symptom. Evidence-gathering only; no index mutation.

**Tasks**:
- [x] **Manual read gate (hard precondition)**: read by hand at least four `chunk_*.md` files per
      document, spread across the document (for `rutten`, the research found symptoms at 0005, 0020,
      0040, 0060; choose an at-least-partly different spread so the finding is independently tested).
      **If either document cannot be read and judged, this phase BLOCKS for it — it does not stamp.**
- [x] For `rutten-2000-universal-coalgebra`: assess whether prose meaning is recoverable despite the
      running-header bleed and corrupted words ("mnning", "detenninistic"), and whether notation
      degradation is confined to formulas or pervades prose. Record the verdict with quoted excerpts
- [x] For `reynolds-2003-ockhamist`: assess the systematic dropped-letter pattern that affects
      ordinary prose and the paper's own title ("Logi of Histori al Ne essity"), not only formulas.
      Record with quoted excerpts
- [x] **Enum-adequacy decision (recorded deliverable)**: state whether the six-value corpus enum can
      express the `reynolds` symptom. The Phase 6 precedent used `unverified_conversion` for "prose
      coherent, formulas degraded"; `reynolds` is worse than that. Per Decision 3, do not invent a
      value — select the nearest existing value, record why the fit is imperfect, and flag the gap
      for the implementation summary
- [x] Record explicitly that `rutten`'s Zotero-stored PDF must **not** be used to assess conversion
      fidelity (Decision 2): it is a different copy from the one chunked, so a favourable comparison
      against it would prove nothing about these chunks
- [x] Capture `doc_type` evidence for both from the same reads
- [x] Append both rows to `data/adjudication.tsv`; write `progress/phase-3-progress.json`

**Timing**: 1.0 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly two degraded entries. If a Phase 2 read reclassifies
a third entry as degraded, that entry's verdict stays in Phase 2's file and this phase's count is
recorded as having grown — the split between phases 2 and 3 is a work-organizing convenience, not a
claim about the corpus. The research's specific symptom descriptions for both entries are hypotheses
to be confirmed or overturned by the implementer's own reads.

**Files to modify**:
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/adjudication.tsv` - two rows
  appended (file created by Phase 2; if Phase 3 runs first, it creates the file with the same header)
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-3-progress.json` - new (created)

**Verification**:
- Both rows name at least four chunk filenames each, all of which exist on disk
- Both verdicts quote at least one concrete degraded excerpt from the implementer's own read
- The enum-adequacy decision for `reynolds-2003-ockhamist` is recorded in prose, with the selected
  value and the reason its fit is imperfect
- Both proposed values are drawn from the existing six-value corpus enum; no new value appears
- `~/Projects/Literature/index.json` unchanged

---

### Phase 4: `doc_type` and `source_format` evidence, including Zotero source-file inspection [IN PROGRESS]

**Goal**: Produce a per-entry, evidence-backed `doc_type` and `source_format` proposal for all twelve,
inspecting the two locatable Zotero PDFs directly and writing a reasoned exclusion for every entry
whose source file genuinely cannot be located. Evidence-gathering only; no index mutation.

**Tasks**:
- [x] Re-confirm both Zotero PDFs still exist on disk:
      `~/Documents/Zotero/storage/2T5LMRXA/Rutten - 2000 - Universal coalgebra a theory of systems.pdf`
      and
      `~/Documents/Zotero/storage/N96JSRYT/Rumberg and Zanardo - 2019 - First-Order Definability of Transition Structures.pdf`
- [x] Open each of the two and confirm author + title + year match the corresponding entry
      (Decision 1's same-work requirement). A mismatch demotes that entry to a reasoned exclusion
- [x] Set `source_format: pdf` for those two, with the inspected absolute path as the recorded evidence
- [x] For `thomason-1970-indeterminist-time`: record the Zotero bibliographic match (`Thomason1970`,
      *Theoria* 36(3), 1970) as `doc_type` evidence, but record `source_format` as `EXCLUDE` — a
      bibliographic record is not a source file
- [x] For the remaining nine: record `source_format` as `EXCLUDE` with per-entry evidence naming both
      the missing `/tmp/task54-lit/<id>.pdf` and the negative Zotero search result. Where the research
      found a *near-miss* (a different Fong & Spivak book, a different Jacobs book, an unrelated
      Reynolds 1992 paper), name the near-miss explicitly so a future reader does not re-run the same
      search hopefully
- [x] Assign `doc_type` for all twelve from the corpus vocabulary only (Decision 3), grounded in the
      Phase 2/3 chunk evidence plus any Zotero record. Give the two BRICS technical reports particular
      attention: there is no `report` value in the corpus vocabulary, so the choice must be justified
      in the evidence column rather than defaulted
- [x] Write `data/scope5-12.tsv` with columns `id`, `proposed_doc_type`, `proposed_source_format`
      (a real value or the literal `EXCLUDE`), `evidence`, mirroring task 457's
      `data/scope5-missing-fields.tsv` schema so the mutation script can reuse its reader
- [x] Draft the `#### Reasoned Exclusions` table rows for every `EXCLUDE`; they are written into this
      plan in Phase 7

**Timing**: 0.75 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research asserts 2 locatable PDFs, 1 bibliographic-record-only entry, and 9
with neither — so 10 `EXCLUDE` rows and 2 `pdf` rows. Confirm each by direct filesystem check and PDF
inspection at implementation time; the split may move in either direction (a PDF may have been moved
or deleted since research, or a fresh search may locate one of the nine).

**Files to modify**:
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/scope5-12.tsv` - new (created)
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-4-progress.json` - new (created)

**Verification**:
- `data/scope5-12.tsv` has exactly twelve rows, one per target id, with no id missing or duplicated
- Every `proposed_doc_type` is one of `chapter`, `paper`, `book`, `section`, `manuscript`, `survey`,
  `thesis`
- Every `proposed_source_format` is either `EXCLUDE` or one of `pdf`, `djvu`, `latex`, `html`
- Every row has a non-empty `evidence` cell; every `EXCLUDE` row names what was searched and not found
- Each non-`EXCLUDE` row names an absolute source path that exists on disk
- `~/Projects/Literature/index.json` unchanged

---

### Phase 5: The mutation — write the five v2 fields on all twelve entries [COMPLETED]

**Goal**: Apply the adjudicated values to `~/Projects/Literature/index.json` in a single wholesale
write, adding exactly five fields to exactly twelve entries and touching nothing else.

**Tasks**:
- [x] Take the pre-mutation backup:
      `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-458-mutate`
- [x] Write `data/migrate12_mutate.py`, adapted from task 457's `data/phase6_mutate.py`. It must:
      read `data/adjudication.tsv` and `data/scope5-12.tsv`; look each entry up by `id`; set
      `provenance_fidelity` **only** from the adjudication TSV (never computed, never inferred);
      compute `token_count = int(chars/4 + 20)` over the concatenation of all `chunk_*.md` in the
      entry's `chunks_dir`; set `path` to the directory relative to `$LITERATURE_DIR` with a trailing
      slash and **no `sources/` prefix**; set `doc_type`; set `source_format` only when the TSV value
      is not `EXCLUDE`
- [x] Give the script a hard precondition: it **refuses to run** (non-zero exit, no write) if any of
      the twelve rows is missing a `provenance_fidelity`, a `doc_type`, or a chunk-filename record —
      the mechanical enforcement of the manual-read gate
- [x] Give the script an explicit allow-list of the twelve ids and of the five mutable keys; it must
      not write any other key on any entry, and must not touch `doc_id`, `id`, `title`, `authors`,
      `year`, `source_path`, `chunks_dir`, `chunk_count`, `ingested_at`, or `schema_normalized_at`
- [x] Run the script; capture its per-entry before/after output into `progress/phase-5-progress.json`
- [x] Immediately re-parse `index.json` and confirm the entry count is unchanged against the Phase 1
      live baseline; on any failure, restore from the pre-mutation backup and stop

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Exactly twelve entries change; exactly five keys are added per entry (four for
the ten `EXCLUDE` entries, which get no `source_format`); no other entry and no other key changes.
Confirm by the Phase 6 field-level diff, not by trusting the script's own reported count.

**Commit-mode note**: `atomic-batch` because `index.json` is rewritten wholesale in a single
operation and the twelve entries are one semantic unit — a corpus in which some of the twelve carry a
`path`/`token_count` pair while others do not is precisely the half-migrated state this task exists to
end. The batch is pre-declared here as: the twelve-entry index write plus `data/migrate12_mutate.py`
plus the progress record. Do not widen it retroactively.

**Files to modify**:
- `~/Projects/Literature/index.json` - five fields added on twelve entries
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/migrate12_mutate.py` - new (created)
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-5-progress.json` - new (created)
- `~/Projects/Literature/index.json.bak-*-pre-458-mutate` - new backup (created)

**Verification**:
- `index.json` parses as JSON and the entry count equals the Phase 1 live baseline
- All twelve entries now carry `provenance_fidelity`, `path`, `token_count`, `doc_type`; and
  `source_format` on exactly the non-`EXCLUDE` subset
- The script's dry refusal path was exercised at least once (e.g. by a deliberately blanked test row
  on a copy) to show the manual-read precondition is enforced, not decorative
- The pre-mutation backup exists and is a valid JSON file

---

### Phase 6: Post-mutation verification gate [NOT STARTED]

**Goal**: Prove the mutation changed exactly what it should have, that the twelve values are
well-formed, and that neither the FTS index nor any other entry was harmed.

**Tasks**:
- [ ] Field-level diff: compare the post-mutation `index.json` against the Phase 5 pre-mutation backup
      and assert that the set of changed entries is exactly the twelve target ids, and that the set of
      changed keys within each is a subset of the five
- [ ] Assert every `provenance_fidelity` is one of the six existing corpus values, and that the twelve
      are **not** all identical unless the evidence file affirmatively defends per-entry uniformity
- [ ] Assert every `path` ends in `/`, does not begin with `sources/`, and resolves to an existing
      directory under `~/Projects/Literature/`
- [ ] **Independently** recompute `token_count` for all twelve with a separate one-off snippet — not
      by re-running `migrate12_mutate.py` — and confirm each matches the stored value exactly
- [ ] Assert every `doc_type` is in the corpus vocabulary and every present `source_format` is in
      `{pdf, djvu, latex, html}`
- [ ] Assert `title`, `authors`, `year`, `doc_id`, `id`, `chunks_dir`, `source_path`, `chunk_count`
      are byte-identical to the backup for all twelve (the Non-Goal, mechanically checked)
- [ ] Run `bash .claude/scripts/literature-build-index.sh --global`; confirm exit 0 and that the
      resulting `chunks_fts` row count is **>= the Phase 1 live baseline**. Record inline that this
      gate cannot fail from these field edits — the build reads `chunks.json` from disk and never
      reads `index.json` — so its real function here is detecting an accidental directory move or
      deletion, not validating the mutation
- [ ] Run `literature-search.sh --include-unverified` for at least two of the twelve and confirm hits;
      record that a default-mode query will **not** surface them, per the known `sources/`-prefix
      defect in `load_fidelity_map()` (Decision 5) — expected behaviour, not a regression introduced here
- [ ] Confirm `specs/literature-index.json` is byte-identical to its pre-task state (none of the
      twelve appear in the sub-index)
- [ ] Write `progress/phase-6-progress.json` with every assertion's outcome

**Timing**: 0.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The FTS row count is expected to equal the Phase 1 baseline exactly, not merely
meet or exceed it — any change at all means something on disk moved, and must be investigated before
the phase closes rather than waved through by the `>=` comparison.

**Files to modify**:
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-6-progress.json` - new (created)
- `~/Projects/Literature/.literature.db` - rebuilt by `literature-build-index.sh --global`

**Verification**:
- Every assertion above is recorded with a PASS/FAIL and its concrete observed value
- Any FAIL halts the phase and triggers the rollback in Rollback/Contingency below; the phase does not
  close on a partial pass

---

### Phase 7: Closeout — exclusions record, carried-forward defects, deferrals [NOT STARTED]

**Goal**: Write the durable records so nothing found here has to be rediscovered: the reasoned
exclusions, the two known code defects carried forward by reference, and the deferred follow-ups.

**Tasks**:
- [ ] Write the `#### Reasoned Exclusions` subsection into Phase 4's body of this plan file, one row
      per `source_format` exclusion, with `Item` / `Reason` / `Evidence` columns, and set Phase 4's
      heading to `[COMPLETED WITH EXCLUSIONS]`
- [ ] Record the two carried-forward code defects **by reference** to task 457's Phase 6 phase notes
      and `progress/phase-6-progress.json` — the `sources/`-only scope of
      `literature-fidelity-audit.sh` and the `sources/` prefix hard-coded in `literature-search.sh`'s
      `load_fidelity_map()`. Do not re-diagnose and do not fix (Decision 5)
- [ ] Record the deferred `title`/`authors`/`year` backfill (Decision 4), naming the three entries
      with real Zotero bibliographic data available (`thomason-1970-indeterminist-time`,
      `rutten-2000-universal-coalgebra`, `rumberg-zanardo-2019-transition-structures`) as the
      tractable subset, so a follow-up starts with evidence rather than a blank search
- [ ] Record the deferred context-documentation subsection (Decision 6), naming the source-store
      ambiguity: this repository has no `agent-system/` tree, so the correct edit target for
      `.claude/context/project/literature/domain/literature-index.md` must be resolved before writing
- [ ] Confirm the `[COMPLETED]` markers on phases 1-6 match their actual outcomes and that the
      plan-level `- **Status**:` field is updated
- [ ] Write `progress/phase-7-progress.json`

**Timing**: 0.5 hours

**Depends on**: 6

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/plans/01_migrate-12-legacy-entries.md` -
  exclusions subsection added, phase statuses updated
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-7-progress.json` - new (created)

**Verification**:
- The `#### Reasoned Exclusions` table has one row per excluded entry, each with non-empty Evidence
- Every deferral names what was deferred, why, and what a follow-up would start from
- No code file outside `specs/**` was modified by this task

---

## Testing & Validation

- [ ] `~/Projects/Literature/index.json` parses as valid JSON after every mutating step
- [ ] Live index entry count after the migration equals the Phase 1 live baseline
- [ ] All twelve target entries carry `provenance_fidelity`, `path`, `token_count`, and `doc_type`
- [ ] `source_format` is present on exactly the non-`EXCLUDE` subset, and every exclusion has a
      reasoned-exclusion row with evidence
- [ ] Every `provenance_fidelity` value is one of the six already present in the corpus; no new enum
      value was introduced
- [ ] Every `doc_type` is one of `chapter`/`paper`/`book`/`section`/`manuscript`/`survey`/`thesis`
- [ ] Every `path` ends in `/`, has no `sources/` prefix, and resolves to a real directory
- [ ] `token_count` for all twelve, recomputed independently of the mutation script, matches the stored
      value exactly
- [ ] `title`, `authors`, `year`, `doc_id`, `id`, `chunks_dir`, `source_path`, `chunk_count` unchanged
      on all twelve
- [ ] No entry outside the twelve changed in any field
- [ ] `bash .claude/scripts/literature-build-index.sh --global` exits 0 and the `chunks_fts` row count
      is >= the Phase 1 live baseline (and any deviation from equality is investigated)
- [ ] `literature-search.sh --include-unverified` returns hits for at least two of the twelve
- [ ] `specs/literature-index.json` is byte-identical to its pre-task state
- [ ] Every one of the twelve has a recorded chunk filename and a hand-written verdict in
      `data/adjudication.tsv`; a stamp without one is a task failure regardless of the other checks

## Artifacts & Outputs

- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/baseline.md` — live pre-migration
  baseline with PASS/DRIFTED verdicts
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/targets12.tsv` — the twelve targets
  with live chunk counts
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/adjudication.tsv` — per-entry
  chunk filenames, hand verdicts, proposed `provenance_fidelity`, `doc_type` evidence
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/scope5-12.tsv` — per-entry
  `doc_type` / `source_format` proposals with evidence and `EXCLUDE` sentinels
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/data/migrate12_mutate.py` — the mutation
  script
- `specs/458_migrate_12_legacy_literature_entries_to_v2_schema/progress/phase-{1..7}-progress.json`
- `~/Projects/Literature/index.json` — twelve entries migrated
- `~/Projects/Literature/index.json.bak-*-pre-458` and `*-pre-458-mutate` — rollback points
- This plan file, updated with phase statuses and the `#### Reasoned Exclusions` record

## Rollback/Contingency

The only mutated artifact outside `specs/**` is `~/Projects/Literature/index.json`, and rollback is a
single file copy:

```
cp ~/Projects/Literature/index.json.bak-<ts>-pre-458-mutate ~/Projects/Literature/index.json
bash .claude/scripts/literature-build-index.sh --global
```

Use the `-pre-458-mutate` backup to undo Phase 5 alone; use the `-pre-458` master backup to return to
the pre-task state. After either restore, re-run the build script and confirm the FTS row count
returns to the Phase 1 live baseline.

Per-phase contingencies:
- **Phase 2 or 3 cannot read a document**: that document BLOCKS. Do not stamp it. Complete the other
  eleven, mark the phase `[PARTIAL]`, and record what prevented the read. A partial migration of
  eleven with an honest gap is a better outcome than twelve stamps of which one is unfounded.
- **Phase 4 finds a Zotero PDF is gone or is a different work**: demote that entry to a reasoned
  exclusion. No re-acquisition attempt — that is out of scope.
- **Phase 5's script refuses to run**: that is the manual-read precondition working. Return to Phase 2
  or 3 for the offending entry rather than relaxing the precondition.
- **Phase 6's field-level diff shows an out-of-scope change**: restore from the pre-mutation backup
  immediately, fix the script's allow-list, and re-run Phase 5. Do not hand-patch the index.

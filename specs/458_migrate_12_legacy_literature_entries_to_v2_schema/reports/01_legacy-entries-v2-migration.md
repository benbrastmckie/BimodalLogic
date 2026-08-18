# Research Report: Task #458

**Task**: 458 - Migrate the 12 remaining legacy `chunks_dir`-only literature entries to the v2 schema
**Started**: 2026-08-18T21:40:00Z
**Completed**: 2026-08-18T22:20:00Z
**Effort**: ~2-3 hours (12 manual chunk reads + 12 field-population edits + verification gate)
**Dependencies**: Task 457 (SCOPE 7 precedent, completed)
**Sources/Inputs**:
- `~/Projects/Literature/index.json` (live, 370 entries as of this research)
- `specs/457_repair_remaining_literature_corpus_data_defects/{plans,data,progress}/*` (Phase 6 template)
- `.claude/scripts/literature-build-index.sh`, `.claude/scripts/literature-fidelity-audit.sh`
- `.claude/context/project/literature/domain/literature-index.md`,
  `.claude/context/project/literature/patterns/chunk-file-conventions.md`
- Chunk directories on disk under `~/Projects/Literature/<id>/`
- `~/Projects/Literature/zotero-library.json`, `~/Documents/Zotero/storage/`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All 12 target entries exist in the live index, are present on disk with `chunk_*.md` counts
  matching `chunk_count` exactly, and are structurally identical to each other (same thin schema,
  same `/tmp/task54-lit/*.pdf` source-path stub, same `schema_normalized_at` stamp from an earlier
  partial migration on 2026-08-05).
- The task 457 Phase 6 precedent for Jönsson-Tarski/Goldblatt was a **narrow, 5-field addition**
  (`provenance_fidelity`, `path`, `token_count`, `doc_type`, `source_format`) layered on top of the
  existing legacy schema — it did **not** rename `doc_id`→`id`, did not remove `chunks_dir`/
  `source_path`, and did not touch `title`/`authors`/`year`. The 12 target entries already carry
  an `id` field (redundant with `doc_id`) from the 2026-08-05 `schema_normalized_at` step that the
  3 SCOPE 7 entries never received — so the precedent's exact 5-field scope is directly reusable
  and no `id`-field backfill is needed.
- `literature-build-index.sh --global` reads `chunks.json` manifests **directly from disk**, not
  from `index.json` — it already indexes all 12 documents' chunks today (verified row counts match
  `chunk_count` for two sampled ids). Mutating `index.json`'s new 5 fields therefore cannot change
  the FTS row count; the post-mutation gate will pass trivially on that axis, exactly as it did in
  Phase 6. The live FTS baseline right now is **17,788** rows (not the 17,736 recorded at the end
  of Phase 6 — an unrelated ingest added a 370th index entry since then), so the next task should
  record a fresh baseline rather than reuse either number.
- `literature-fidelity-audit.sh` is scoped to `sources/<dir>/` paths only (confirmed from its own
  header) and will never see or corroborate any of these 12 — matches the task description's
  premise exactly, and matches the same code-level reason already documented in Phase 6.
- All 12 source PDFs at `/tmp/task54-lit/*.pdf` are gone (ephemeral tmp path from a much earlier
  ingest). However, cross-referencing `zotero-library.json` and `~/Documents/Zotero/storage/`
  found: **2 of 12 have a real, locatable local PDF** (`rutten-2000-universal-coalgebra`,
  `rumberg-zanardo-2019-transition-structures`), **1 of 12 has a genuine bibliographic record but
  no stored PDF** (`thomason-1970-indeterminist-time`), and the remaining **9 of 12 have neither**.
  This is new evidence beyond what the task description anticipated ("inspect the actual source
  file if present") — the planner should decide whether Zotero cross-referencing is in scope
  before defaulting all 12 to a bare `source_format` exclusion.
- Manual sampling (multiple chunks per document, prose read by hand) found the 12 documents are
  **not uniform in fidelity**: at least 7 read cleanly (BRICS-96-35, BRICS-94-7,
  Cattani-Winskel-2005, both Schultz-Spivak papers, Fong-Speranzon-Spivak, Danos-Krivine,
  Jacobs-coalgebra-draft, Thomason-1970 all sampled clean), while **2 show clear OCR degradation**
  (`rutten-2000-universal-coalgebra`: garbled running headers bleeding into body text, corrupted
  words like "mnning"/"detenninistic", degraded formula notation; `reynolds-2003-ockhamist`: a
  systematic dropped-letter pattern affecting ordinary prose words, not just formulas — e.g. "Logi
  of Histori al Ne essity" for "Logic of Historical Necessity" — plus heavily garbled diagram/
  formula content). This is evidence for the manual adjudication step, not an adjudication itself.

## Context & Scope

Task 458 is a direct follow-up to task 457's Phase 6 (SCOPE 7), which adjudicated and migrated 3
named legacy `chunks_dir`-only entries (Jönsson-Tarski 1951/1952, Goldblatt 2006). That phase
explicitly deferred the other 12 legacy-schema entries to a spawned follow-up task (Planning
Decision 2 in `specs/457_.../plans/01_corpus-data-repairs.md`) rather than widening SCOPE 7's
manual-read burden. This research investigates the current live state of those 12 entries, confirms
the Phase 6 template is directly reusable, and surfaces evidence relevant to each entry's
`doc_type`/`source_format`/`provenance_fidelity` adjudication so a subsequent plan can execute with
minimal re-discovery.

This is research only — no mutation of `~/Projects/Literature/index.json` was performed. All
counts and content excerpts below were read directly from the live filesystem/index during this
research pass.

## Findings

### Live Index State (as of this research)

- `~/Projects/Literature/index.json` currently has **370 entries, 362 distinct ids** (up from the
  369/361 baseline recorded at the end of task 457 — a new, unrelated entry
  `roberts_-_2025_-_necessity_in_the_highest_degree` was ingested since then). The corpus is
  confirmed to still be a moving target; a future plan should re-derive live counts rather than
  reuse either the 369/361 or 370/362 figures as a frozen baseline, per the same discipline task
  457's plan applied throughout.
- The 8-id duplicate-entry defect (task 459's scope, unrelated to this task) is still present and
  unaffected by anything found here.
- All 12 target ids are present exactly once each in the live index, keyed and matched
  successfully via `.id` (no lookup ambiguity — unlike the SCOPE 7 3, which had to be matched via
  `.id or .doc_id` fallback because they lacked an `id` field at Phase 6 time).

### Current Schema of the 12 Target Entries

Every one of the 12 currently has this exact field set (example, `brics-rs-96-35`):

```json
{
  "doc_id": "brics-rs-96-35",
  "title": "brics-rs-96-35",
  "authors": [],
  "year": null,
  "source_path": "/tmp/task54-lit/brics-rs-96-35.pdf",
  "chunks_dir": "/home/benjamin/Projects/Literature/brics-rs-96-35",
  "chunk_count": 38,
  "ingested_at": "2026-08-05T12:54:31Z",
  "id": "brics-rs-96-35",
  "schema_normalized_at": "2026-08-05T12:55:23Z"
}
```

Notably: `title` is just the id string (not a real title), `authors` is empty, `year` is `null`.
This is thinner than the SCOPE 7 3's pre-migration state — those came from a Zotero-linked
online-ingest bridge with real title/authors/year/`zotero_key`/`zotero_path` already populated;
these 12 came from a bare `/tmp/task54-lit/*.pdf` ingest bridge (task 54, 2026-08-05) with no
Zotero linkage and only placeholder title/author/year. **The task 458 description's required field
list (`path`/`token_count`/`doc_type`/`source_format`/`provenance_fidelity`) does not include
`title`/`authors`/`year` backfill** — consistent with Phase 6 leaving those untouched for the 3
it migrated. This gap is real but appears intentionally out of this task's scope; flagging it here
so the planner makes that exclusion an explicit Non-Goal rather than an oversight (mirroring how
457's plan wrote explicit Non-Goals for adjacent deferred work).

Missing fields, all 12: `provenance_fidelity`, `path`, `token_count`, `doc_type`, `source_format`.

### Post-Migration Schema Shape (the Phase 6 Precedent, Concretely)

After Phase 6, the 3 SCOPE 7 entries look like this (`goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution`, full entry):

```json
{
  "doc_id": "goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution",
  "title": "Mathematical modal logic: A view of its evolution",
  "authors": ["Goldblatt, Robert"],
  "year": 2006,
  "source_path": "/home/benjamin/Documents/Zotero/storage/64V2FN77/Goldblatt - MATHEMATICAL MODAL LOGIC A VIEW OF ITS EVOLUTION.pdf",
  "chunks_dir": "/home/benjamin/Projects/Literature/goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution",
  "chunk_count": 199,
  "ingested_at": "2026-08-18T18:10:42Z",
  "doi": null,
  "arxiv_id": null,
  "zotero_key": "JSFMAID3",
  "zotero_path": "/home/benjamin/Documents/Zotero/storage/64V2FN77/Goldblatt - MATHEMATICAL MODAL LOGIC A VIEW OF ITS EVOLUTION.pdf",
  "provenance_fidelity": "verified_conversion",
  "path": "goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution/",
  "token_count": 75619,
  "doc_type": "chapter",
  "source_format": "pdf"
}
```

Key observations for planning task 458's target shape:
- `doc_id` was **kept**, not renamed to `id` (no `id` field was added for these 3 — an
  inconsistency Phase 6 left in place; the 12 already have `id` so this doesn't recur).
- `chunks_dir`, `source_path` were **kept** (not removed) — this is not a "delete legacy fields"
  migration, only an "add the 5 missing v2 fields" migration.
- `path` is relative to `$LITERATURE_DIR`, **no `sources/` prefix** (these directories live
  directly under `~/Projects/Literature/<id>/`, not under `sources/<id>/`), with a trailing slash:
  `"<id>/"`. This is the exact form the 12 target entries need too, since their `chunks_dir` is
  likewise `~/Projects/Literature/<id>` directly (confirmed below, not under `sources/`).
- `token_count` was computed as `chars/4+20` over the **concatenation of all `chunk_*.md` files**
  in the directory (not any canonical whole-document `.md`, which does not exist in these
  directories — see "Chunk File Convention Applicability" below).
- `doc_type` here is `"chapter"` (Goldblatt 2006 is a book chapter); the Jönsson-Tarski pair are
  `"paper"`. Confirms `doc_type` values already in use in the corpus are the ones to reuse (per
  SCOPE 5's approach), not a fixed vocabulary invented per-task.

The reusable mutation script for this precedent is
`specs/457_repair_remaining_literature_corpus_data_defects/data/phase6_mutate.py` — it is a
directly adaptable template: read `chunks_dir`, glob `chunk_*.md`, sum `len(text)` per file,
`token_count = int(chars/4 + 20)`, set `path` to `f"{dirpath.relative_to(LIT_DIR)}/"`, and only
set `provenance_fidelity` from a `TARGETS` dict populated **after** the manual read (never
computed automatically). `doc_type`/`source_format` population followed the separate SCOPE 5
pattern (`phase5_mutate.py`, driven by a hand-built TSV of per-entry evidence with an `EXCLUDE`
sentinel for `source_format` when no source file exists — see below).

### Chunk Directories on Disk (all 12 confirmed present and consistent)

Every one of the 12 has its `chunks_dir` directly under `~/Projects/Literature/<id>/` (not under
`sources/`), containing only `chunk_*.md`, `chunks.json`, and `metadata.json` — **no canonical
whole-document `.md` file** in any of the 12. `chunk_*.md` file counts match the index's stored
`chunk_count` exactly for every entry:

| id | chunk_count (index) | chunk_*.md on disk | source PDF at `/tmp/task54-lit/` |
|----|---------------------|---------------------|-----------------------------------|
| brics-rs-96-35 | 38 | 38 | missing |
| cattani-winskel-2005-profunctors | 129 | 129 | missing |
| brics-rs-94-7 | 76 | 76 | missing |
| schultz-spivak-temporal-type-theory | 236 | 236 | missing |
| fong-speranzon-spivak-temporal-landscapes | 31 | 31 | missing |
| schultz-spivak-vasilakopoulou-dynamical-systems-sheaves | 45 | 45 | missing |
| thomason-1970-indeterminist-time | 77 | 77 | missing |
| rutten-2000-universal-coalgebra | 353 | 353 | missing |
| jacobs-coalgebra-intro-draft | 1448 | 1448 | missing |
| danos-krivine-rccs | 32 | 32 | missing |
| reynolds-2003-ockhamist | 29 | 29 | missing |
| rumberg-zanardo-2019-transition-structures | 41 | 41 | missing |

`metadata.json` in each directory is a duplicate of the legacy `index.json` entry (same
`doc_id`/`title`/`authors`/`year`/`source_path`/`chunks_dir`/`chunk_count`/`ingested_at` fields,
no additional clues) — it is not a useful secondary source for `doc_type`/`source_format`
evidence.

`chunk_0000.md` is 0 bytes for every one of the 12 (a title-page image with no extractable text —
this is expected and not itself evidence of degradation; content starts at `chunk_0001.md`).

### Chunk File Convention Applicability (a documented exception, not a conflict)

`.claude/context/project/literature/patterns/chunk-file-conventions.md` documents a rule that
whole-document computations under `sources/<dir>/` MUST exclude `chunk_*.md` and use the canonical
`.md` instead, to avoid double-counting. That rule presumes a canonical `.md` exists alongside the
chunk re-splits. **None of the 12 target directories have a canonical `.md`** — only the chunk
files exist — so there is nothing to double-count against, and summing `chunk_*.md` directly (as
Phase 6's `phase6_mutate.py` already did for the 3 SCOPE 7 entries, and as the task 458 description
explicitly directs: "chars/4+20 over concatenated chunk_*.md text") is the only correct approach
here. This is the same situation Phase 6 encountered, not a new one.

### `literature-build-index.sh --global` Behavior (confirmed by reading the script and querying the live DB)

The build script (`.claude/scripts/literature-build-index.sh`) does **not** read `index.json` at
all. It globs `find "$target_dir" -name "chunks.json"` under the target directory (the whole
`~/Projects/Literature/` tree when `--global` is passed — not restricted to `sources/`), and for
each manifest inserts every chunk's `doc_id`/`chunk_id`/content-preview into `chunks_data`, then
rebuilds the `chunks_fts` FTS5 virtual table from that. Verified directly against the live
`~/Projects/Literature/.literature.db`:

```
SELECT count(*) FROM chunks_fts;                                    -- 17788 (current live total)
SELECT count(*) FROM chunks_data WHERE doc_id='brics-rs-96-35';     -- 38  (matches chunk_count)
SELECT count(*) FROM chunks_data WHERE doc_id='rutten-2000-universal-coalgebra'; -- 353 (matches)
```

This means **all 12 documents' chunks are already indexed in the live FTS database today**, prior
to any `index.json` mutation — because the build reads `chunks.json` manifests directly from disk,
completely independent of `index.json`'s `provenance_fidelity`/`path`/`token_count`/`doc_type`/
`source_format` fields. A future task's `--global` rebuild-and-compare-row-count gate will
therefore trivially pass on this axis (the row count cannot drop from these specific field edits),
exactly as it did in Phase 6 — the gate's real value is guarding against an unrelated accidental
directory move/deletion, not against the metadata edits themselves.

**Baseline correction**: Phase 6's own recorded post-mutation FTS row count was 17,736. The live
count right now is **17,788** (52 more), because an unrelated ingest (`roberts_-_2025_-...`, noted
above) added rows since Phase 6 completed. A future plan must record a fresh pre-mutation baseline
at its own Phase 1 rather than reuse 17,736.

### `literature-fidelity-audit.sh` Scope Confirmation

Read directly from the script's own header comment: it classifies `sources/<dir>/` directories
only, matching `index.json` entries whose `.path` starts with `sources/<dir>/`. All 12 target
directories live directly under `~/Projects/Literature/<id>/`, not under `sources/`, so the audit
script will never match, scan, or produce corroborating output for any of them — confirming the
task description's premise exactly, and reproducing the identical code-level finding Phase 6
already recorded (`specs/457_.../progress/phase-6-progress.json`'s `audit_corroboration` /
`new_code_level_finding` fields) for the 3 SCOPE 7 entries. The manual chunk read remains the sole
adjudication evidence for all 12, same as for the 3.

**Downstream consequence worth carrying forward** (already documented for the SCOPE 7 3, applies
identically here, not a new finding to fix): `literature-search.sh`'s `load_fidelity_map()`
hard-codes a `path` prefix of `"sources/"` when resolving `provenance_fidelity` for default (non-
`--include-unverified`) search ranking. Once these 12 entries' `path` fields are stamped (correctly,
without a `sources/` prefix, per the directory-path convention), default search will silently
treat all 12 as `unverified_summary` regardless of their true stamped value — including any that
get `verified_conversion`. This is the same pre-existing code-level defect Phase 6 already
recorded and explicitly left unfixed (agent-system code change, out of a data-only task's scope);
a plan for task 458 should reference rather than re-diagnose it.

### `doc_type`/`source_format` Evidence Per Entry

The task description's instruction ("inspect the actual source file if present; record as a
reasoned exclusion if not") assumes the only candidate source is the file named in `source_path`.
For all 12, that path (`/tmp/task54-lit/<id>.pdf`) is gone — `/tmp` is ephemeral and the ingest
that used it (task 54) predates this research by weeks. Confirmed missing for all 12.

This research additionally cross-referenced `~/Projects/Literature/zotero-library.json` (a
Better-BibTeX CSL-JSON export, 200 entries) and `~/Documents/Zotero/storage/` (943 attachment
directories) by author/title keyword, since a genuine Zotero-linked PDF would be stronger evidence
than a blanket exclusion. Results:

| id | Zotero bibliographic record found | Local PDF located | Evidence for `source_format` |
|----|-----|-----|-----|
| thomason-1970-indeterminist-time | Yes — `Thomason1970`, "Indeterminist Time and Truth-Value Gaps", Thomason, Richmond H., *Theoria* 36(3), 1970 | No (storage search for "thomason"/"indeterminist" found only an unrelated 1984 Thomason paper) | Real title/authors/year available; no PDF — `source_format` still a reasoned exclusion unless the paper is re-acquired |
| rutten-2000-universal-coalgebra | Yes — `Rutten2000`, "Universal coalgebra: a theory of systems", Rutten J.J.M.M., *Theoretical Computer Science* 249, 2000 | **Yes** — `~/Documents/Zotero/storage/2T5LMRXA/Rutten - 2000 - Universal coalgebra a theory of systems.pdf` | `source_format: pdf` is directly evidenced, not an exclusion |
| rumberg-zanardo-2019-transition-structures | Yes — `Rumberg2019`, "First-Order Definability of Transition Structures", Rumberg, Antje; Zanardo, Alberto, *J. Logic, Language and Information* 28(3), 2019 | **Yes** — `~/Documents/Zotero/storage/N96JSRYT/Rumberg and Zanardo - 2019 - First-Order Definability of Transition Structures.pdf` | `source_format: pdf` is directly evidenced, not an exclusion |
| brics-rs-96-35 | No | No | reasoned exclusion (no source file on disk, no Zotero cross-reference) |
| brics-rs-94-7 | No | No | reasoned exclusion |
| cattani-winskel-2005-profunctors | No | No | reasoned exclusion |
| schultz-spivak-temporal-type-theory | No | No | reasoned exclusion |
| fong-speranzon-spivak-temporal-landscapes | No | No (a *different* Fong & Spivak 2019 book was found; not this paper) | reasoned exclusion |
| schultz-spivak-vasilakopoulou-dynamical-systems-sheaves | No | No | reasoned exclusion |
| jacobs-coalgebra-intro-draft | No (a *different* Jacobs 2001 book, "Categorical Logic and Type Theory", was found; not this draft) | No | reasoned exclusion |
| danos-krivine-rccs | No | No | reasoned exclusion |
| reynolds-2003-ockhamist | No (only an unrelated Reynolds 1992 paper found) | No | reasoned exclusion |

This is a materially different outcome from a blanket "no source file, exclude all 12" treatment:
**2 of 12 have directly evidenced `source_format: pdf`**, groundable exactly the way SCOPE 5's
per-entry evidence approach requires (inspect the actual source file — here, the Zotero-stored
copy rather than the vanished `/tmp` copy). A plan should decide explicitly whether Zotero
cross-referencing is in scope for this migration (it is a natural reading of "inspect the actual
source file if present" — the file is present, just not at the stale `source_path`) or whether to
hold to a narrower reading (only the literal `source_path` counts) and exclude all 12. Either is
defensible; this research surfaces the fact rather than deciding it.

Note: even for the 2 entries with a locatable Zotero PDF, this is **not** the same PDF that was
chunked (the chunking predates any Zotero linkage) — using it only grounds `source_format`/
possibly `doc_type`/real `title`/`authors`/`year`, not a re-conversion of content. Re-converting is
explicitly out of scope per the established Non-Goals precedent ("This pass edits index metadata
only; it never rewrites source markdown").

### Manual Content Sampling (evidence for the fidelity adjudication step; not an adjudication)

Per the task's required process (manual chunk read, not an automated ratio — `literature-fidelity-audit.sh` cannot corroborate here), this research opened and read chunk samples from all 12 directories. This is evidence-gathering only; the actual `provenance_fidelity` stamp must still be written by the implementer after their own read, per the hard precondition in Phase 6 ("If any of the three cannot be read and judged, this phase BLOCKS — it does not stamp" — the same rule applies here).

Findings, roughly by symptom:

**Read cleanly** (prose and available notation legible across the sampled chunks):
- `brics-rs-96-35` — presheaf-models-for-concurrency paper (author names not stated in the sampled chunk, "Glynn Winskel" appears in metadata `section_path`); clean prose.
- `brics-rs-94-7` — "Bisimulation from op[en maps]" — authors visible mid-document: André Joyal, Mogens Nielsen, Glynn Winskel; clean.
- `cattani-winskel-2005-profunctors` — abstract chunk fully legible: "This paper studies fundamental connections between profunctors... open maps and bisimulation..."; clean.
- `schultz-spivak-temporal-type-theory`, `fong-speranzon-spivak-temporal-landscapes`, `schultz-spivak-vasilakopoulou-dynamical-systems-sheaves` — all three sampled clean (2KB-class chunks with coherent prose, no visible OCR corruption in the sampled ranges).
- `thomason-1970-indeterminist-time` — sampled clean; matches its real Zotero title "Indeterminist Time and Truth-Value Gaps".
- `jacobs-coalgebra-intro-draft` — preface chunk clean and coherent ("Mathematics is about the formal structures underlying counting, measuring, transforming..."); minor repeated "FT" token noise (likely a running footer/watermark artifact) but does not obscure content.
- `danos-krivine-rccs` — clean ("Backtracking means rewinding one's computation trace...").
- `rumberg-zanardo-2019-transition-structures` — clean ("In Burgess (1980), Peirceanism is proven to be axiomatizable...").

**Visible OCR degradation** (evidence a fidelity stamp of less than fully-verified is likely warranted, pending the implementer's own read):
- `rutten-2000-universal-coalgebra` — multiple sampled chunks (0005, 0020, 0040, 0060) show running-header text bleeding into body paragraphs ("J.J.M.M. R1111,•11/Tlw11r<'lical C11111p111a Sci<'•tn• 249..."), corrupted ordinary words ("mnning" for "running", "detenninistic" for "deterministic"), and garbled inline mathematical notation (chunk 0060: `"1  s..!C.s'  = as(.•l(•l~l."` for what is presumably a transition-relation definition). Prose meaning is still largely recoverable but degradation is more pervasive than an isolated formula-only symptom.
- `reynolds-2003-ockhamist` — a systematic dropped-letter OCR pattern, most visibly the letter "c", affecting **ordinary prose and the paper's own title**, not only formulas: "An Axiomatization of Prior's Logi of Histori al Ne essity" for "...Logic of Historical Necessity"; "su h that" for "such that"; "onne ted" for "connected". A sampled figure (a Kamp-frame diagram) and inline temporal-logic formulas are heavily garbled with dropped subscripts. This is a more pervasive degradation than the Jönsson-Tarski precedent (where prose was clean and only mathematical notation degraded) — worth the implementer's particular attention, since it may not fit either of Phase 6's two precedent verdicts (`verified_conversion` / `unverified_conversion` for "prose coherent, formulas degraded") cleanly; a third outcome or a closer per-chunk read may be warranted.

No chunk sampled for any of the 12 showed mojibake-level corruption or duplicated content (the two falsifier symptoms task 457's plan explicitly checked for in its own SCOPE 3 risk mitigation) — all 12 are readable prose to varying degrees, consistent with "OCR degradation of varying severity" rather than "conversion failure."

## Decisions

None — this is a research report; no mutations were made and no `provenance_fidelity`/`doc_type`/
`source_format` values were written. The findings above are evidence for a subsequent plan and
implementation to use, not decisions binding that work.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Treating all 12 as uniformly `unverified_conversion` (or uniformly anything) without per-entry read, given the visible spread from clean to significantly degraded found here | H | M | Require the same hard precondition Phase 6 used: open and read at least one chunk per document, stamp only after; this research's sampling is corroborating evidence, not a substitute. |
| Assuming `source_format` must be a blanket exclusion for all 12 because the literal `source_path` is gone | M | M | This research found 2 of 12 (Rutten, Rumberg-Zanardo) have a real, locatable Zotero-stored PDF; a plan should decide explicitly whether cross-referencing counts as "the actual source file" before excluding those two. |
| Reusing a stale FTS-row-count baseline (17,736 from Phase 6, or the 369/361 entry-count baseline) as the post-mutation gate target | M | M | The corpus has drifted since Phase 6 (370/362 entries now, 17,788 FTS rows now); record a fresh baseline at the start of the next phase, per the same live-recomputation discipline task 457's plan applied throughout. |
| `reynolds-2003-ockhamist`'s degradation pattern (prose-level letter-dropping, not just formula garbling) may not map cleanly onto the two-value precedent (`verified_conversion` / `unverified_conversion`) established by Phase 6 | M | L | Flagged explicitly above; the implementer's own read should decide whether the existing enum is adequate or whether this entry needs closer inspection before stamping. |
| The `sources/`-prefix bug in `literature-search.sh`'s `load_fidelity_map()` will quarantine all 12 from default search once stamped, exactly as it already does for the 3 SCOPE 7 entries | L | H (certain, given the code as read) | Already a known, documented, out-of-scope code defect (agent-system code); reference the existing Phase 6 finding rather than re-diagnosing or attempting a fix in a data-only task. |

## Context Extension Recommendations

- **Topic**: Legacy `chunks_dir`-only entries lacking a Zotero PDF have no reliable path to a
  genuine `doc_type`/`source_format` without either re-acquisition or an accepted convention for
  "the id string doubles as a citation key; treat as `unverified`/excluded until acquired."
- **Gap**: `.claude/context/project/literature/domain/literature-index.md` documents the v2 schema
  fields but does not document the "5-field partial migration" pattern this task and Phase 6 both
  use (add only `provenance_fidelity`/`path`/`token_count`/`doc_type`/`source_format` onto an
  otherwise-untouched legacy `doc_id`-keyed entry, leaving `chunks_dir`/`source_path`/`title`/
  `authors`/`year` as-is). A short "Partial v2 Migration for chunks_dir-only Entries" subsection
  there, referencing this report and `specs/457_.../progress/phase-6-progress.json` as the worked
  example, would save a future migration task from re-deriving this from source.
- **Recommendation**: Add that subsection during or after this task's implementation (not a
  blocking prerequisite for planning task 458).

## Appendix

### Search/Investigation Steps Used

- Read `specs/457_.../plans/01_corpus-data-repairs.md`, `data/phase6_mutate.py`,
  `data/phase2_mutate.py`, `data/phase5_mutate.py`, `data/scope7-legacy.tsv`,
  `data/scope5-missing-fields.tsv`, and `progress/phase-6-progress.json` for the concrete template
  and worked precedent.
- `python3 json.load` over `~/Projects/Literature/index.json` (370 entries) to inspect the 12
  target entries, the 3 already-migrated entries, and 3 native-v2 sibling entries
  (`diamondsareforever`, `brast-mckie_2026_construction-possible-worlds`,
  `goldblatt_2023_strong-completeness-real-time`) for schema-shape comparison. (Direct `jq` regex
  matching on `.id` hit a `null`-indexing error on an unrelated entry mid-array; Python's `json`
  module was used instead for all index inspection to avoid that.)
- Filesystem checks (`ls`, `find`) confirming all 12 `chunks_dir` directories exist, `chunk_*.md`
  counts match `chunk_count`, no canonical whole-document `.md` exists in any of the 12, and all 12
  `/tmp/task54-lit/*.pdf` source files are gone.
- `sqlite3` queries against the live `~/Projects/Literature/.literature.db` to confirm the current
  FTS row count (17,788) and that two sampled ids' chunks are already present in `chunks_data`
  independent of `index.json` state.
- Keyword cross-reference of `zotero-library.json` (200 entries) and a `find` sweep of
  `~/Documents/Zotero/storage/` (943 attachment directories) by author surname/title keyword for
  all 12 ids, surfacing 3 bibliographic matches (2 with a locatable local PDF).
- Direct reads of multiple `chunk_*.md` files per document (`head -c`, `cat`) across all 12
  directories to assess prose/formula legibility by hand.

### References

- `specs/457_repair_remaining_literature_corpus_data_defects/plans/01_corpus-data-repairs.md`
  (Phase 6, Planning Decision 2, Non-Goals, Risks table)
- `specs/457_repair_remaining_literature_corpus_data_defects/data/phase6_mutate.py`,
  `data/phase5_mutate.py`, `data/scope5-missing-fields.tsv`
- `specs/457_repair_remaining_literature_corpus_data_defects/progress/phase-6-progress.json`
- `.claude/scripts/literature-build-index.sh`, `.claude/scripts/literature-fidelity-audit.sh`
- `.claude/context/project/literature/domain/literature-index.md`
- `.claude/context/project/literature/patterns/chunk-file-conventions.md`

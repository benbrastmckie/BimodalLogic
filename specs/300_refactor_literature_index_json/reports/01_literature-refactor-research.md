# Research Report: Task #300

**Task**: 300 - Refactor specs/literature/ to use index.json files for --lit flag compatibility
**Started**: 2026-06-14T00:00:00Z
**Completed**: 2026-06-14T00:00:00Z
**Effort**: ~1 hour
**Dependencies**: None
**Sources/Inputs**: Codebase exploration of BimodalLogic and cslib specs/literature/ directories, literature-retrieve.sh, CLAUDE.md
**Artifacts**: specs/300_refactor_literature_index_json/reports/01_literature-refactor-research.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- `literature-retrieve.sh` already has full index.json support — the BimodalLogic literature directory simply needs an `index.json` file created to enable keyword-based selective retrieval.
- The cslib project provides a production-quality reference: a 988-line master `index.json` with 42 entries covering both single-file papers and multi-part book subdirectories with per-subdirectory `index.json` files.
- BimodalLogic has 30 `.md` summary files (excluding README.md) and 33 `.pdf` files; 5 PDFs have no corresponding MD (reference-only PDFs that should be listed in the index with `path: null` or excluded), and 2 MDs have no corresponding PDF (Thomas 1997 .md only, Libkin 2004 uses a renamed chapter MD).
- The `fallback path` in `literature-retrieve.sh` (used when no `index.json` exists) picks up ALL `.md` files including README.md and would include up to 10 files without keyword filtering; adding `index.json` enables precise semantic retrieval within the TOKEN_BUDGET=4000 limit.
- Recommended approach: create a single flat `index.json` in `specs/literature/` with one entry per `.md` file; no subdirectory refactoring needed since none of the BimodalLogic papers are split into chapter subdirectories.

## Context & Scope

### What Was Researched

1. The cslib reference implementation at `/home/benjamin/Projects/cslib/specs/literature/`
2. The current BimodalLogic literature directory at `/home/benjamin/Projects/BimodalLogic/specs/literature/`
3. The `literature-retrieve.sh` script that implements `--lit` flag injection
4. The CLAUDE.md documentation for `--lit` flag semantics

### Constraints

- PDFs must be kept in place (they are source documents for the .md summaries)
- PDFs must be ignored during literature retrieval (only .md content injected)
- The index.json structure must match what `literature-retrieve.sh` expects

## Findings

### Current cslib Structure

The cslib `specs/literature/` uses a two-level index pattern:

**Top-level `index.json`** (988 lines, 42 entries): One entry per `.md` file with fields:
```json
{
  "id": "burgess_1982_i",
  "bib_key": "Burgess1982I",
  "title": "Axioms for Tense Logic. I. \"Since\" and \"Until\"",
  "authors": "John P. Burgess",
  "year": 1982,
  "section": null,
  "path": "burgess_1982_i.md",
  "page_range": "367-374",
  "token_count": 4995,
  "keywords": ["tense logic", "Until operator", "Since operator", ...],
  "summary": "One-sentence description..."
}
```

**Per-book subdirectory `index.json`** (in e.g. `gentzen_1935/index.json`): Lists chapters with `file`, `title`, `pages`, `token_count`, `keywords` fields. Used for human reference; the top-level `index.json` is what `literature-retrieve.sh` reads.

**Key observations**:
- The `path` field in top-level entries points to `.md` files: either `author_year.md` (flat) or `book_dir/chapter.md` (subdirectory)
- PDFs are present in the directory (`Blackburn_deRijke_Venema_2002_Modal_Logic.pdf`) but have no entries in `index.json` — they are silently ignored
- Book-length files are split into chapter subdirectories; paper-length files remain as top-level `.md` files
- The `bib_key` field links to `references.bib` entries (can be `null`)

### Current BimodalLogic Structure

The BimodalLogic `specs/literature/` is a flat directory with no `index.json`:

**File inventory** (64 total files):
- 33 PDF files
- 30 `.md` summary files (active content)
- 1 `README.md` (should be excluded from index entries; it's a directory-level document)

**Markdown files** (30 content files to index):
```
Blackburn_deRijke_Venema_2002_Modal_Logic.md
Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md
Burgess_1982b_Axioms_for_tense_logic_II_Time_periods.md
Burgess_1984_Basic_Tense_Logic.md
Caleiro_Vigano_Volpe_2013_Mosaic_Method_Tense_Modal.md
deRijke_Venema_1995_Sahlqvist_BAOs.md
Doets_1987_Completeness_and_Definability_thesis.md
Doets_1989_Monadic_Pi11_Theories.md
Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md
Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md
Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md
Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md
Goldblatt_Hodkinson_Venema_2003_BAOs_Modal_Logic.md
Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md
Libkin_2004_Elements_Finite_Model_Theory_ch3_ch7.md
Obendrauf_2024_Lean_Formalization_Coalition_Logic.md
Rabinovich_2014_Proof_of_Kamps_Theorem.md
Reynolds_1992_Axiomatization_Until_Since_without_IRR.md
Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md
Reynolds_2001_Axiomatization_Full_CTL_star.md
Thomas_1997_EF_Games_Composition_Monadic.md
Thomason_1984_Combinations_of_Tense_and_Modality.md
Venema_1991_Many_Dimensional_Modal_Logics_app_A_B.md
Venema_1991_Many_Dimensional_Modal_Logics_ch2.md
Venema_1993_Derivation_Rules_Anti_Axioms.md
Venema_1993_Since_and_Until.md
Venema_1997_Atom_Structures_Sahlqvist.md
Venema_2001_Temporal_Logic_Survey.md
Verbrugge_2004_Completeness_by_construction.md
Xu_1988_On_some_US_tense_logics.md
```

**PDFs without MDs** (reference-only; no index entry needed):
```
A Concise Introduction to Propositional Dynamic Logic (Krister Segerberg) (z-library.sk, 1lib.sk, z-lib.sk).pdf
Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1.pdf    (full book; ch9/10/12 have MDs)
Gabbay_Reynolds_2000_Temporal_Logic_Foundations_Vol2.pdf               (not yet converted)
Libkin_2004_Elements_Finite_Model_Theory.pdf                           (chapter extraction is _ch3_ch7.md)
Venema_1991_Many_Dimensional_Modal_Logics.pdf                          (full book; ch2 + app A/B have MDs)
```

**MDs without PDFs**:
```
Libkin_2004_Elements_Finite_Model_Theory_ch3_ch7.md   (chapter extraction from Libkin_2004...pdf)
Thomas_1997_EF_Games_Composition_Monadic.md            (no PDF obtained; MD reconstructed from secondaries)
```

Note: Both MDs-without-PDFs are valid index entries — they have `.md` content files.

### How literature-retrieve.sh Works

The script has two code paths:

**Index path** (when `index.json` exists AND description is non-empty):
1. Extract keywords from task description and task_type (stop-word filtered, >3 chars, top 10)
2. Score each index entry by keyword overlap against `entry.keywords[]` + bonus if keyword in `entry.summary`
3. Greedy-select entries within TOKEN_BUDGET=4000 and MAX_FILES=10, sorted by score descending
4. For each selected entry: read `$LIT_DIR/$entry.path` and include content with title header
5. Emit `<literature-context>` block on stdout

**Fallback path** (when no `index.json` or no keywords):
1. `find "$LIT_DIR" -type f ( -name "*.md" -o -name "*.txt" ) ! -name "index.json" | sort`
2. Include files up to TOKEN_BUDGET (word count estimate) and MAX_FILES=10
3. Does NOT skip README.md — would include it as first file alphabetically
4. No keyword filtering — takes whatever fits in budget

The `path` field in index.json entries is relative to `$LIT_DIR`, so entries should be like `"path": "Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md"`.

**Critical behavior**: The index path reads `full_path="$LIT_DIR/$entry_path"` and does `[ -f "$full_path" ]` before including. PDFs are simply not referenced by any index entry, so they are never read.

### No Script Changes Needed

The `literature-retrieve.sh` script is already fully compatible with the cslib index.json pattern. The `index.json` schema it expects matches what cslib produces. The only change needed is creating the `index.json` file in BimodalLogic's `specs/literature/`.

## Decisions

- **No subdirectory splitting**: Unlike cslib which splits book-length files into chapter subdirectories, BimodalLogic already has chapter-level `.md` files at the top level (e.g., `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`). No restructuring needed.
- **PDF-only files excluded**: The 5 PDF-only files (Segerberg, GHR Vol 1 full, GHR Vol 2, Libkin full, Venema 1991 full) have no `.md` summaries and should not appear in `index.json`.
- **README.md excluded**: The README.md is a directory-level navigation document, not a literature summary. It should not appear in `index.json` (the fallback path picks it up; the index path would not).
- **Naming convention retained**: BimodalLogic uses Pascal-case filenames (e.g., `Burgess_1982...md`) rather than cslib's lowercase convention (e.g., `burgess_1982_i.md`). The `path` field in `index.json` must exactly match the actual filenames.
- **Token counts**: Should be estimated as `word_count * 1.3` per the cslib schema comment. These can be computed with `wc -w` on each file.
- **Keyword overlap with cslib**: Some entries exist in both BimodalLogic and cslib (e.g., Burgess 1982, Blackburn/de Rijke/Venema 2002). The cslib `index.json` keyword arrays can be reused for matching entries.

## Risks & Mitigations

- **README.md included by fallback but not index path**: Once `index.json` exists, the index path is used for all tasks with non-empty descriptions. The fallback path (which picks up README.md) only triggers if there are no keywords — rare in practice. This is acceptable behavior.
- **Token count estimates may be off**: The `word_count * 1.3` formula is approximate. If a file's actual token count is significantly higher than estimated, it may consume budget faster than expected. Mitigation: use conservative estimates or run wc -w on each file during index creation.
- **GHR 1994 chapters (ch9, ch10, ch12)**: Three chapter MDs for Gabbay/Hodkinson/Reynolds 1994 Volume 1 are indexed as separate entries. They share the same authors/year/bib_key but have different paths and keywords. This is the correct approach (same as cslib's per-chapter entries for multi-part works).

## Gap Analysis: What Needs to Change

| Item | Current State | Target State |
|------|---------------|--------------|
| `specs/literature/index.json` | Absent | 30-entry JSON file, schema matching cslib |
| `literature-retrieve.sh` | Already supports index.json | No changes needed |
| CLAUDE.md `--lit` documentation | Refers to all .md/.txt files | No changes needed (description is accurate) |
| PDF files | Present (ignored by fallback via -name "*.md") | No changes needed |
| README.md | Picked up by fallback path | Will be excluded by index path once index.json added |

## Implementation Notes for Planner

The implementation is straightforward:

1. **Compute token counts**: Run `wc -w` on each of the 30 `.md` files, multiply by 1.3, round to integer
2. **Draft index entries**: For each file, determine `id`, `bib_key`, `title`, `authors`, `year`, `section`, `page_range`, `keywords`, `summary`
3. **Assign keywords**: 6-10 keywords per entry; use the README.md topic groupings as a guide for relevant terms
4. **Write `specs/literature/index.json`**: Single flat file, `version: 1`, `token_budget: 4000`, `max_chunks: 10`
5. **Verify**: Test with `bash .claude/scripts/literature-retrieve.sh "kamp theorem temporal logic" "lean4"` and confirm relevant papers are selected

The GHR 1994 chapters need special attention since they share a bib_key ("GHR94") but are separate files. Suggested IDs:
- `gabbay_1994_ch9` -> `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md`
- `gabbay_1994_ch10` -> `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`
- `gabbay_1994_ch12` -> `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md`

The Venema 1991 dissertation has two chapter extracts:
- `venema_1991_ch2` -> `Venema_1991_Many_Dimensional_Modal_Logics_ch2.md`
- `venema_1991_app` -> `Venema_1991_Many_Dimensional_Modal_Logics_app_A_B.md`

## Context Extension Recommendations

This task is meta-type; context extension recommendations are omitted per agent system instructions.

## Appendix

### Search Queries Used

- Local filesystem: `ls /home/benjamin/Projects/BimodalLogic/specs/literature/`
- Local filesystem: `ls /home/benjamin/Projects/cslib/specs/literature/`
- Local filesystem: `ls /home/benjamin/Projects/cslib/specs/literature/gentzen_1935/`
- Read: `/home/benjamin/Projects/cslib/specs/literature/index.json`
- Read: `/home/benjamin/Projects/cslib/specs/literature/gentzen_1935/index.json`
- Read: `/home/benjamin/Projects/cslib/specs/literature/blackburn_2001/index.json`
- Read: `/home/benjamin/Projects/cslib/specs/literature/hughes_1996/index.json`
- Read: `/home/benjamin/Projects/cslib/specs/literature/README.md`
- Read: `/home/benjamin/Projects/BimodalLogic/specs/literature/README.md`
- Read: `/home/benjamin/Projects/BimodalLogic/.claude/scripts/literature-retrieve.sh`
- Bash: PDF/MD mismatch analysis

### References

- cslib `specs/literature/index.json`: production reference implementation (42 entries)
- cslib `specs/literature/README.md`: documents the index.json schema inline
- `literature-retrieve.sh`: the consumer of `index.json`; already fully supports the format

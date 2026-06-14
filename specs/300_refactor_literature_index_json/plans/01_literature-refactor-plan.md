# Implementation Plan: Task #300

- **Task**: 300 - Refactor specs/literature/ to use index.json for --lit flag compatibility
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/300_refactor_literature_index_json/reports/01_literature-refactor-research.md
- **Artifacts**: plans/01_literature-refactor-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a single `specs/literature/index.json` file with 30 entries (one per `.md` summary file, excluding README.md) following the cslib schema. The `literature-retrieve.sh` script already supports index.json-based keyword-scored retrieval; the only missing piece is the index file itself. Once created, `--lit` flag usage will switch from unfiltered alphabetical file inclusion to semantic keyword-based selection within the TOKEN_BUDGET=4000 limit. No script changes, no directory restructuring, and no CLAUDE.md updates are needed.

### Research Integration

The research report confirmed:
- `literature-retrieve.sh` has full index.json support via a keyword-scoring code path that activates when `index.json` is present
- The cslib project provides a production reference with 42 entries using the schema: `{id, bib_key, title, authors, year, section, path, page_range, token_count, keywords[], summary}`
- BimodalLogic has exactly 30 `.md` files to index and 33 PDFs to keep but ignore
- PDFs are naturally excluded because `index.json` entries only reference `.md` paths

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation required for this meta task.

## Goals & Non-Goals

**Goals**:
- Create `specs/literature/index.json` with entries for all 30 `.md` summary files
- Follow the cslib schema exactly (id, bib_key, title, authors, year, section, path, page_range, token_count, keywords, summary)
- Enable keyword-based selective retrieval via `--lit` flag
- Keep all PDFs in place, undisturbed

**Non-Goals**:
- Modifying `literature-retrieve.sh` (already compatible)
- Restructuring the directory layout or creating subdirectories
- Converting PDFs to markdown
- Updating CLAUDE.md documentation (already accurate)
- Creating per-subdirectory index.json files (no subdirectories exist)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Token count estimates inaccurate | L | M | Use `wc -w` on each file and multiply by 1.3; conservative rounding |
| Keyword selection too narrow | M | L | Use 6-10 keywords per entry covering topic, method, and key terms |
| Path field mismatch with actual filenames | H | L | Use exact filenames from `ls` output; verify all paths exist after creation |
| Missing or incorrect metadata for obscure papers | L | L | Cross-reference README.md topic groupings and file contents for accuracy |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Create specs/literature/index.json [NOT STARTED]

**Goal**: Create the complete index.json file with 30 entries following the cslib schema, compute token counts, and verify the file works with `literature-retrieve.sh`.

**Tasks**:
- [ ] Run `wc -w` on all 30 `.md` files in `specs/literature/` (excluding README.md) to compute word counts
- [ ] Compute token counts as `ceil(word_count * 1.3)` for each file
- [ ] For each of the 30 files, create an index entry with all required fields:
  - `id`: lowercase author_year format (e.g., `burgess_1982_i`)
  - `bib_key`: PascalCase citation key (e.g., `Burgess1982I`)
  - `title`: Full paper/chapter title
  - `authors`: Author name(s)
  - `year`: Publication year (integer)
  - `section`: Chapter/section identifier or `null` for standalone papers
  - `path`: Exact filename of the `.md` file (e.g., `Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`)
  - `page_range`: Page range string or `null` if unknown
  - `token_count`: Computed token estimate (integer)
  - `keywords`: Array of 6-10 keywords covering topic, method, and key concepts
  - `summary`: One-sentence description of the paper's contribution
- [ ] Handle multi-part works with distinct IDs:
  - GHR 1994 chapters: `gabbay_1994_ch9`, `gabbay_1994_ch10`, `gabbay_1994_ch12`
  - Venema 1991 chapters: `venema_1991_ch2`, `venema_1991_app`
- [ ] Write the complete JSON to `specs/literature/index.json` with top-level structure: `{"version": 1, "token_budget": 4000, "max_chunks": 10, "entries": [...]}`
- [ ] Validate JSON syntax with `jq . specs/literature/index.json`
- [ ] Verify all 30 paths resolve: for each entry, confirm `test -f specs/literature/$path` succeeds
- [ ] Test retrieval: run `bash .claude/scripts/literature-retrieve.sh "kamp theorem temporal logic" "lean4"` and confirm relevant papers are selected
- [ ] Test retrieval with a second query: run `bash .claude/scripts/literature-retrieve.sh "modal logic completeness" "lean4"` to verify keyword diversity

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `specs/literature/index.json` - New file; 30-entry index following cslib schema

**Verification**:
- `jq '.entries | length' specs/literature/index.json` returns 30
- All 30 paths resolve to existing files
- `literature-retrieve.sh` with a topic query returns a non-empty `<literature-context>` block with relevant papers (not just alphabetically first files)
- No PDFs or README.md appear in the index entries

---

## Testing & Validation

- [ ] JSON is valid: `jq . specs/literature/index.json` exits 0
- [ ] Entry count is 30: `jq '.entries | length' specs/literature/index.json` returns 30
- [ ] All paths exist: `jq -r '.entries[].path' specs/literature/index.json | while read p; do test -f "specs/literature/$p" || echo "MISSING: $p"; done` produces no output
- [ ] No PDFs referenced: `jq -r '.entries[].path' specs/literature/index.json | grep -c '\.pdf$'` returns 0
- [ ] No README.md referenced: `jq -r '.entries[].path' specs/literature/index.json | grep -c 'README'` returns 0
- [ ] Keyword retrieval works: `bash .claude/scripts/literature-retrieve.sh "temporal logic until since" "lean4"` returns non-empty output
- [ ] Token counts are reasonable: `jq '[.entries[].token_count] | add' specs/literature/index.json` returns a total (should be roughly 50,000-150,000)

## Artifacts & Outputs

- `specs/literature/index.json` - The index file (sole deliverable)
- `specs/300_refactor_literature_index_json/plans/01_literature-refactor-plan.md` - This plan

## Rollback/Contingency

Delete `specs/literature/index.json` to revert to the fallback retrieval path (alphabetical file scan). No other files are modified by this task, so rollback is trivial.

# Implementation Plan: Task #915

- **Task**: 915 - Re-convert and re-index reynolds_2001 with sections 5-8 included
- **Status**: [NOT STARTED]
- **Effort**: 3.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/915_reconvert_reindex_reynolds_auxiliary_atoms_sections/reports/01_reynolds-sections-5-8-reconversion.md`
- **Artifacts**: plans/01_reynolds-sections-5-8-splice.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The `reynolds_2001` conversion in `~/Projects/Literature/sources/reynolds_2001/` skips the
paper's own §5-§8 (PDF pages 1024-1028), which is exactly where the Auxiliary Atoms rule is
stated (§7, Definition 4, Lemma 6), alongside the Limit Closure axiom (§6, Lemma 5) and the
combined system `⊢_c` (§8, Definition 5, Theorem 3). This plan closes that four-section gap by a
**surgical splice**, not a whole-document reconversion: the §5-§8 span is extracted from a
scratch conversion pass, hand-fitted to the neighbor sections' house style, installed as four new
`secNN_*.md` files, spliced into `chunks.json` as four new entries with a re-linked
`prev`/`next` chain, and picked up by a global FTS5 rebuild. Done when
`literature-search.sh "auxiliary atoms"` returns the new §7 chunk with `doc_id: reynolds_2001`
and `--toc reynolds_2001` shows §1-§16 with no gap.

### Research Integration

The research report settled four decisions this plan is built on, each of which removes a step a
naive plan would have included:

- **No whole-document reconversion.** A scratch-directory test run of
  `literature-convert.sh` reported `Quality gate: PASSED` but produced markedly worse markdown
  than the existing hand-curated sections (nearly every paragraph wrapped in spurious `**bold**`,
  5-6 detected headings against the paper's 17 real sections, a spurious Tesseract OCR fallback
  on a born-digital title page). The gate does not check for that defect, so `PASSED` is not a
  house-style-parity signal. `sec01-03` and the current `sec04-10` content stay byte-for-byte
  unchanged apart from filename renumbering.
- **No `literature-chunk.sh` invocation.** This document's established convention is one chunk
  per paper §-section regardless of size (existing `token_count` values run 862-3894, far above
  that script's 512-token target and 1024-token atomic cap). Running it would re-chunk and
  renumber the whole document. The four new `chunks.json` entries are hand-authored using the
  script's documented chunk-ID formula instead.
- **`--global` rebuild only.** This repo's `specs/literature/` is deprecated and holds no
  `.literature.db`, so `literature-search.sh` already falls straight through to the global DB; a
  `--local` rebuild would find no manifests and is a no-op here.
- **`specs/literature-index.json` needs no structural change.** The sub-index is reference-only
  by design, and its existing `reason` text already cites "sec 6, Lemma 5" and "sec 7, Lemma 6" —
  confirmed accurate against the PDF. Only a dated addendum recording that those sections now
  exist is warranted.

The report's Finding 2 verbatim §5-§8 quotations (cross-checked against two independent
extractions, `pdftotext -layout` and `pymupdf4llm`) are the reference text Phase 1's hand-fitting
is diffed against.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context; no roadmap consultation was
performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- The paper's §5, §6, §7, §8 present as four new per-section markdown files in
  `~/Projects/Literature/sources/reynolds_2001/`, in the neighbor files' house style.
- `chunks.json` carrying four matching entries with correctly computed `chunk_id`s and a
  prev/next chain re-linked across the insertion point.
- The global FTS5 index rebuilt so that a `literature-search.sh` query for the Auxiliary Atoms
  rule returns the new §7 chunk.
- A dated addendum on `specs/literature-index.json`'s `reynolds_2001` entry recording that the
  §5-§8 gap is closed.

**Non-Goals**:
- Regenerating or reformatting any existing section's *content* (`sec01-03` and current
  `sec04-10`). Filenames shift; bytes inside them do not.
- Splitting §7 into multiple chunks to satisfy `literature-chunk.sh`'s token budget — this
  document does not follow that budget and §7's ~1510-token size is within its actual convention.
- Rebuilding a local `.literature.db` (none exists in this repo).
- Chasing the literature briefing's "~66084 tokens" figure for this document, which disagrees
  with both the global index's `token_count` and the chunk-sum. Out of scope per the report.
- Writing the `partial-document-splice.md` context pattern the report recommends — that is a
  separate deliverable, not part of this task's scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hand-fitting §5-§8 introduces a transcription error in a formula (AA rule side condition, Definition 4's quantifier structure) | H | M | Phase 1 diffs its final §6/§7 text against the report's Finding 2 verbatim quotations and against a live `pdftotext -layout` extraction before the text leaves the scratch directory |
| Renumbering `sec04-sec10` to `sec08-sec14` with an ascending `git mv` order overwrites a file that still exists (e.g. `sec04` -> `sec08` while `sec08` is live) | H | M | Phase 2 renames in strictly **descending** order (sec10->sec14 first, sec04->sec08 last) and verifies 14 distinct files exist afterward |
| A `chunks.json` `source_path` left pointing at a pre-renumber filename | M | M | Phase 2 updates filenames and `source_path` fields together; Phase 2 and Phase 4 both assert every `source_path` resolves on disk |
| A miscomputed `chunk_id` or a broken prev/next link leaves the new chunks unreachable by `--read`/navigation even though FTS5 finds them | M | M | Phase 3 computes IDs with the exact documented formula in a script (not by hand) and asserts the full 14-entry chain is a single unbroken linked list with no duplicate IDs |
| Committing `Literature/` changes under this repo's `task {N}:` convention | L | M | `~/Projects/Literature/` is a separate git repository; Phase 4 commits there under that repo's own conventions, and Phase 5 commits the `specs/` change separately in `BimodalLogic` |
| A global index rebuild regresses search for other documents in the corpus | M | L | Phase 4 captures a pre-rebuild baseline count of indexed chunks and compares after, and runs the literature suites named in its Tier Justification |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Extract and hand-fit §5-§8 into scratch [NOT STARTED]

**Goal**: Produce four house-style-conformant markdown section files for §5-§8 in the session
scratch directory, verified against the PDF, without touching the live `Literature/` tree.

**Tasks**:
- [ ] Run `bash .claude/scripts/literature-convert.sh /home/benjamin/Projects/Literature/sources/reynolds_2001/Reynolds_2001_Axiomatization_Full_CTL_star.pdf <scratch_dir>` to obtain full-document text (engine `auto` -> `pymupdf4llm`).
- [ ] Run `pdftotext -layout` on the same PDF as the independent cross-check extraction.
- [ ] Cut the §5-§8 span: from `§5. The axiom system for bundled trees` through §8's Theorem 3, stopping immediately before `§9. Completeness preliminaries`.
- [ ] Split the span into four files, one per §-section.
- [ ] Hand-fit each to neighbor house style: strip the spurious `**bold**` paragraph wrapping, promote each `§N. <opening clause>` run to a `##` heading matching `sec03`/`sec04`'s exact shape, and restore the corpus's Unicode conventions (`§`, `⊢_B`, `⊢_c`, `⊨_B`, `⊨_c`).
- [ ] Diff the §6 and §7 text against the research report's Finding 2 verbatim quotations (LC axiom schema and Lemma 5; Definition 4, the AA rule statement, and Lemma 6) and against the `pdftotext` extraction; correct any divergence.
- [ ] Record a `char/4` token estimate per file for Phase 3's `token_count` fields.

**Timing**: 1.0 hour

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for these scratch markdown paths — no suite covers them — so the covering check is the `prose` row's diff read-through, here against two independent PDF extractions plus the report's Finding 2 quotations.

**Files to modify**:
None in any tracked tree. This phase writes only to the implementer's own session scratchpad
directory: four files named `sec04_axiom-system-bundled-trees.md` (§5), `sec05_limit-closure-axiom.md`
(§6), `sec06_auxiliary-atoms-rule.md` (§7), and `sec07_the-theorem.md` (§8), plus the
`literature-convert.sh` output they are cut from. Phase 3 installs them into the live tree; the
scratch paths are deliberately not declared as scope because they are session-local and name no
tracked file.

**Verification**:
- Four files exist in the scratch directory, each opening with a `##` heading matching the neighbor sections' shape.
- No residual `**`-wrapped full paragraphs remain (spot-check by grep for lines that are entirely bold).
- §6's Lemma 5 statement, §7's Definition 4 / AA rule / Lemma 6 statements, and §8's Theorem 3 statement each match the report's Finding 2 quotations.

---

### Phase 2: Renumber the existing section files [NOT STARTED]

**Goal**: Free the `sec04`-`sec07` slots by shifting the existing `sec04`-`sec10` files to
`sec08`-`sec14`, with `chunks.json`'s `source_path` fields updated in lockstep.

**Tasks**:
- [ ] In `~/Projects/Literature/sources/reynolds_2001/`, `git mv` the seven files in **strictly descending** order: `sec10`->`sec14`, `sec09`->`sec13`, `sec08`->`sec12`, `sec07`->`sec11`, `sec06`->`sec10`, `sec05`->`sec09`, `sec04`->`sec08`, preserving each filename's slug portion unchanged.
- [ ] Update the seven corresponding `source_path` values in `chunks.json` to the new filenames, leaving every other field (including `chunk_id`, `prev_chunk_id`, `next_chunk_id`, `token_count`) untouched.
- [ ] Assert all 10 current `source_path` values resolve to existing files.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns the `__FULL_SWEEP__` sentinel over this phase's touched path set (the renamed `.md` files map to no suite, which subsumes `chunks.json`'s own coverage), so no suite covers this phase and the covering check is the `local` row's lint of the single changed artifact — the scripted `chunks.json` JSON-validity and `source_path`-resolution assertions this phase's Verification block names.

**Scope Hypothesis**: Exactly seven existing files (`sec04`-`sec10`) require renaming and exactly seven `chunks.json` `source_path` fields require updating, leaving `sec01`-`sec03` untouched. The implementer confirms this by listing `sec*.md` in the document directory and counting `source_path` occurrences in `chunks.json` before starting; if the counts differ from seven, stop and re-derive the mapping from the actual `section_path` ordering rather than applying the rename list blindly.

**Files to modify**:
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/chunks.json` - seven `source_path` values updated to the renumbered filenames
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec04_sec-9-completeness-preliminaries-in-what.md` - renamed to `sec08_...` (content unchanged)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec05_sec-10-the-standard-basis-of-the-constru.md` - renamed to `sec09_...` (content unchanged)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec06_111-lulls-it-will-be-important-in-our-co.md` - renamed to `sec10_...` (content unchanged)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec07_132-a-new-chronicle-we-check-that-t.md` - renamed to `sec11_...` (content unchanged)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec08_143-hue-scheduling-assuming-that-there-i.md` - renamed to `sec12_...` (content unchanged)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec09_sec-15-truth-lemma-ko-and-the-truth-lemm.md` - renamed to `sec13_...` (content unchanged)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec10_sec-16-examples.md` - renamed to `sec14_...` (content unchanged)

**Verification**:
- `ls sec*.md` shows exactly ten files, numbered `sec01`-`sec03` and `sec08`-`sec14`, with `sec04`-`sec07` free.
- Every `source_path` in `chunks.json` resolves to an existing file (scripted existence check over all 10 entries).
- `git diff` in the `Literature/` repo shows renames with no content change (`git diff --stat -M` reports pure renames for the seven files).

---

### Phase 3: Install the new section files and splice chunks.json [NOT STARTED]

**Goal**: The four hand-fitted §5-§8 files live in the document directory as `sec04`-`sec07`, and
`chunks.json` carries four matching new entries in a single unbroken 14-entry chain.

**Tasks**:
- [ ] Copy the four Phase 1 scratch files into `~/Projects/Literature/sources/reynolds_2001/` as `sec04_axiom-system-bundled-trees.md`, `sec05_limit-closure-axiom.md`, `sec06_auxiliary-atoms-rule.md`, `sec07_the-theorem.md`.
- [ ] Write a short script computing each new `chunk_id` as `sha256(f"reynolds_2001\x00{section_path}\x00{content[:64]}").hexdigest()[:16]` — the exact formula `literature-chunk.sh` uses — rather than computing any ID by hand.
- [ ] Insert four entries into `chunks.json` between the existing `§4.7-4.8` entry and the `§9` entry, with `section_path`/`title` set to `"§5. The Axiom System for Bundled Trees"`, `"§6. The Limit Closure Axiom"`, `"§7. The Auxiliary Atoms Rule"`, `"§8. The Theorem"`; `doc_id: "reynolds_2001"`, `level: 1`, `parent_chunk_id: null`, `cross_refs: []` (matching every existing entry), `source_path` set to the new filenames, `token_count` from Phase 1's estimates, and `keywords`/`summary` in the existing entries' style (`summary` as `"Chapter: <section_path>"`).
- [ ] Re-link the chain: the `§4.7-4.8` entry's `next_chunk_id` -> new §5 chunk; new §8 chunk's `next_chunk_id` -> the §9 chunk; the §9 entry's `prev_chunk_id` -> new §8 chunk; and the three internal links among §5-§8.
- [ ] Assert the manifest is valid JSON with 14 entries, no duplicate `chunk_id`, every `source_path` resolving, and the prev/next links forming one list from the §1-3 head to the §16 tail.

**Timing**: 0.75 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns the `__FULL_SWEEP__` sentinel over this phase's touched path set (the four new `.md` files map to no suite, which subsumes `chunks.json`'s own coverage), so no suite covers this phase and the covering check is the `local` row's lint of the single changed artifact — the scripted manifest assertions (14 entries, distinct IDs, resolving `source_path`s, unbroken chain) this phase's Verification block names.

**Scope Hypothesis**: Exactly four new `chunks.json` entries are added and exactly two existing entries (`§4.7-4.8` and `§9`) have a link field changed, for a 14-entry manifest. The implementer confirms this by re-counting entries and re-walking the chain after the splice; if the pre-splice count is not 10, re-derive the insertion point from `section_path` ordering instead of from entry indices.

**Files to modify**:
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec04_axiom-system-bundled-trees.md` - new; §5 content installed from scratch
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec05_limit-closure-axiom.md` - new; §6 content installed from scratch
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec06_auxiliary-atoms-rule.md` - new; §7 content installed from scratch
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec07_the-theorem.md` - new; §8 content installed from scratch
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/chunks.json` - four new entries spliced in; `next_chunk_id`/`prev_chunk_id` re-linked on the two bracketing entries

**Verification**:
- `chunks.json` parses, holds 14 entries, has 14 distinct `chunk_id` values, and every `source_path` resolves on disk.
- Walking `next_chunk_id` from the §1-3 head reaches all 14 entries exactly once and terminates at the §16 entry; walking `prev_chunk_id` backward from the tail does the same.
- Each new `chunk_id` reproduces exactly when the documented formula is re-applied to the installed file's content.

---

### Phase 4: Rebuild the global index and verify retrieval [NOT STARTED]

**Goal**: The global FTS5 index contains the four new chunks and a search for the Auxiliary Atoms
rule returns the new §7 chunk.

**Tasks**:
- [ ] Capture a pre-rebuild baseline: total indexed chunk count in `~/Projects/Literature/.literature.db` and the `reynolds_2001` chunk count (expected 10).
- [ ] Run `bash .claude/scripts/literature-build-index.sh --global`.
- [ ] Compare post-rebuild counts: `reynolds_2001` at 14, corpus total up by exactly 4 against the baseline.
- [ ] Run `bash .claude/scripts/literature-search.sh "auxiliary atoms"` and confirm a `reynolds_2001` §7 result; repeat with a second query (e.g. `"limit closure axiom"` or `"AA rule sound"`) as a cross-check.
- [ ] Run `bash .claude/scripts/literature-search.sh --toc reynolds_2001` and confirm the §1-§16 sequence with no gap between §4.7-4.8 and §9.
- [ ] Run `bash .claude/scripts/literature-search.sh --read <new §7 chunk_id>` and confirm it returns the §7 text.
- [ ] Commit the `Literature/` repo changes (renames, four new files, `chunks.json`) under **that repository's own** conventions — not this repo's `task {N}:` format.

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns `test-literature-build-index.sh`, `test-literature-search.sh`, and `test-lit-pipeline.sh` for the rebuilt `.literature.db`, so the covering check is `bash .claude/scripts/tests/run-all.sh --only test-literature-build-index.sh,test-literature-search.sh` (`test-lit-pipeline.sh` lives outside this repo's `scripts/tests/` directory and is reached by the Phase 5 full gate).

**Files to modify**:
- `/home/benjamin/Projects/Literature/.literature.db` - regenerated by the global index rebuild

**Verification**:
- `reynolds_2001` has 14 indexed chunks; corpus-wide total is the baseline plus exactly 4 (no other document's coverage changed).
- `literature-search.sh "auxiliary atoms"` returns a `reynolds_2001` §7 result — the task's stated acceptance condition.
- `--toc reynolds_2001` shows no gap between §4.7-4.8 and §9.
- `--read` on the new §7 `chunk_id` returns §7's text.
- `bash .claude/scripts/tests/run-all.sh --only test-literature-build-index.sh,test-literature-search.sh` passes.

---

### Phase 5: Record the reindex in the sub-index and close out [NOT STARTED]

**Goal**: `specs/literature-index.json`'s `reynolds_2001` entry records that §5-§8 are now
present, and the full gate set passes.

**Tasks**:
- [ ] Add a dated addendum to the existing `reynolds_2001` entry in `specs/literature-index.json` — a `"reindexed"` field carrying the date and the fact that §5-§8 (LC axiom, AA rule, Theorem 3) are now converted and indexed. Leave the `reason`, `added`, `source`, and `citation_rule` text unchanged: the `reason` field's "sec 6, Lemma 5" / "sec 7, Lemma 6" citations were confirmed accurate against the PDF by the research phase and need no correction. (Correction target confirmed present at authoring time: the entry exists in `specs/literature-index.json`. If it is absent when this phase runs, add the entry fresh with the same `doc_id` and `citation_rule` rather than skipping the step.)
- [ ] Optional drive-by: refresh the stale `token_count` on `~/Projects/Literature/index.json`'s `reynolds_2001` entry to the true chunk-sum (pre-existing staleness, 32665 recorded against a 33419 sum; post-splice sum ≈ 36200). Skip if it would expand the change surface; it is not part of this task's deliverable, and the briefing's separate "~66084" figure is explicitly out of scope.
- [ ] Run the full gate set and confirm green.
- [ ] Commit the `BimodalLogic` `specs/` change separately, in this repository, under this repo's `task {N}:` convention.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- `specs/literature-index.json` - dated `reindexed` addendum on the `reynolds_2001` entry
- `/home/benjamin/Projects/Literature/index.json` - optional `token_count` refresh on the `reynolds_2001` entry

**Verification**:
- `specs/literature-index.json` parses as valid JSON and the `reynolds_2001` entry carries the dated addendum with its other fields byte-identical to before.
- The complete gate set passes: `bash .claude/scripts/verify-deploy.sh`.
- `literature-search.sh "auxiliary atoms"` still returns the §7 chunk after all edits.

---

## Testing & Validation

- [ ] `chunks.json` is valid JSON with 14 entries, 14 distinct `chunk_id` values, every `source_path` resolving on disk, and an unbroken prev/next chain in both directions.
- [ ] Each new `chunk_id` is reproducible from the documented formula applied to the installed file content.
- [ ] `ls sec*.md` shows ten renumbered existing files (`sec01`-`sec03`, `sec08`-`sec14`) plus four new ones (`sec04`-`sec07`).
- [ ] `git diff --stat -M` in the `Literature/` repo shows the seven shifted files as pure renames with no content change.
- [ ] `reynolds_2001` has 14 indexed chunks in the global DB; the corpus total rose by exactly 4.
- [ ] `bash .claude/scripts/literature-search.sh "auxiliary atoms"` returns a `reynolds_2001` §7 result.
- [ ] `bash .claude/scripts/literature-search.sh --toc reynolds_2001` shows §1-§16 with no gap.
- [ ] §6's Lemma 5, §7's Definition 4 / AA rule / Lemma 6, and §8's Theorem 3 match the research report's Finding 2 verbatim quotations.
- [ ] `bash .claude/scripts/verify-deploy.sh` passes.

## Artifacts & Outputs

- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec04_axiom-system-bundled-trees.md` (§5, new)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec05_limit-closure-axiom.md` (§6, new)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec06_auxiliary-atoms-rule.md` (§7, new — the task's target source statement)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec07_the-theorem.md` (§8, new)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec08_...`-`sec14_...` (the seven renumbered existing files, content unchanged)
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/chunks.json` (14 entries)
- `/home/benjamin/Projects/Literature/.literature.db` (rebuilt global FTS5 index)
- `specs/literature-index.json` (dated `reindexed` addendum on the `reynolds_2001` entry)
- `specs/915_reconvert_reindex_reynolds_auxiliary_atoms_sections/summaries/01_reynolds-sections-5-8-splice-summary.md` (implementation summary)

## Rollback/Contingency

The work spans two repositories, each independently revertible:

- **`Literature/` repo**: the renames, new files, and `chunks.json` splice land in one commit
  there (Phase 4). Reverting that commit restores the ten original filenames and the 10-entry
  manifest; a subsequent `bash .claude/scripts/literature-build-index.sh --global` restores the
  index to its pre-splice state. The `.literature.db` is a derived artifact and is always
  recoverable by rebuilding from the manifests, so it needs no separate backup.
- **`BimodalLogic` repo**: the `specs/literature-index.json` addendum is a single additive JSON
  field in its own commit (Phase 5); reverting that commit is sufficient.
- **Mid-phase failure before either commit**: if uncommitted work in the `Literature/` tree must
  be discarded, follow `context/contracts/recovery.md`'s rollback rung for the snapshot-then-
  rollback invocation shape (including its out-of-scope override flag, which applies here because
  the affected tree lies outside this task's `file_scope`) rather than running a bare destructive
  git command.
- **Partial-completion stance**: Phases 2-3 leaving the manifest mid-splice is the one genuinely
  inconsistent intermediate state (renamed files, un-spliced entries). It is detectable by the
  `source_path`-resolution assertion both phases run, and is repaired forward by completing
  Phase 3 rather than by reverting Phase 2.

# Research Report: Task #915

**Task**: 915 - Re-convert and re-index reynolds_2001 with sections 5-8 included
**Started**: 2026-11-10
**Completed**: 2026-11-10
**Effort**: small (single-document corpus splice)
**Dependencies**: None
**Sources/Inputs**:
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/` (existing conversion, 10 chunks)
- `Reynolds_2001_Axiomatization_Full_CTL_star.pdf` (primary source, pages 1011-1057)
- `.claude/scripts/literature-convert.sh`, `literature-chunk.sh`, `literature-build-index.sh`, `literature-search.sh`
- `specs/literature-index.json` (BimodalLogic sub-index entry for `reynolds_2001`)
- `/home/benjamin/Projects/Literature/index.json` (global index entry for `reynolds_2001`)
**Artifacts**:
- `specs/915_reconvert_reindex_reynolds_auxiliary_atoms_sections/reports/01_reynolds-sections-5-8-reconversion.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The paper's own §5-§8 (pages 1024-1028) are genuinely missing from the corpus. The existing
  10-chunk conversion jumps from `§4.7-4.8. Equivalence Results and Inequivalence` straight to
  `§9. Completeness Preliminaries`, exactly as the task description states.
- The Auxiliary Atoms (AA) rule's actual source statement is confirmed to live at **§7
  ("The auxiliary atoms rule"), Definition 4, and Lemma 6** ("The AA rule is sound for ⊢_C"); the
  companion Limit Closure (LC) axiom is at **§6, Lemma 5**; the combined system is named at **§8
  ("The theorem"), Definition 5 and Theorem 3**. This exactly matches the claim already recorded
  in the BimodalLogic sub-index entry's `reason` field — that field needs no correction.
- **A naive full-document re-run of `literature-convert.sh` is the wrong implementation
  strategy.** A test conversion (see Findings) produced markedly worse markdown than the existing
  hand-curated sections — most paragraphs spuriously wrapped in `**bold**`, only 5-6 detected
  headings against the paper's 17 sections, and a spurious Tesseract OCR fallback on page 0. Using
  it to regenerate the *whole* document would silently regress the already-good §1-4/§9-16
  content.
- The recommended approach is a **surgical splice**: extract only the missing §5-§8 span from a
  fresh conversion pass, hand-fit it to the neighbor files' house style, insert 4 new per-section
  `.md` files renumbered into the existing `secNN_*.md` sequence, splice 4 matching entries into
  `chunks.json` (chunk-ID algorithm confirmed below), and rebuild only the **global** FTS5 index
  (`literature-build-index.sh --global`) — this repo's `specs/literature/` is a deprecated,
  `.literature.db`-less fallback, so no `--local` rebuild is needed or possible here.
- `specs/literature-index.json`'s existing sub-index entry for `reynolds_2001` is structurally
  fine as-is (it is a reference-only pointer per `literature-index.md`'s schema, not a chunk
  cache); the task's "refreshed entry" deliverable is satisfied by confirming its `reason` text
  stays accurate once §5-§8 exist, with an optional dated addendum noting the reindex.

## Context & Scope

Task 915's goal is narrow: the forward-cone unravelling research (task 559's chain) needed a
citable primary-source statement of the Auxiliary Atoms rule and used the repo's own
`NamingRules.lean` Saturation obligation instead, because `literature-search.sh "auxiliary
atoms"` returns nothing relevant and the existing `reynolds_2001` conversion skips the sections
where the rule is actually stated. This research phase verifies exactly what is missing, exactly
where the rule's source text lives, and what the correct mechanical procedure is to add it to the
corpus without damaging what is already there. It does not perform the reconversion/reindex
itself — that is this task's planning/implementation phase.

## Findings

### 1. The gap is real and precisely bounded

`chunks.json` for `reynolds_2001` (10 entries) has this section sequence, confirmed by reading
the manifest directly:

| # | `section_path` | source file |
|---|---|---|
| 1 | §1-3. Introduction and CTL* Language/Semantics | `sec01_an-axiomatization-of-full-computation-tr.md` |
| 2 | §4. PLTL Axiom System | `sec02_a.md` |
| 3 | §4.7-4.8. Equivalence Results and Inequivalence | `sec03_47-equivalence-results-there-are-two-equ.md` |
| 4 | **§9. Completeness Preliminaries** | `sec04_sec-9-completeness-preliminaries-in-what.md` |
| 5 | §10. The Standard Basis of the Construction | `sec05_...md` |
| 6-10 | §11.1, §13.2, §14.3, §15, §16 | `sec06..sec10_...md` |

`pdftotext -layout` on the source PDF confirms the paper's own `?N.` (§) heading markers in order:
§1, §2, §3, §4, **§5, §6, §7, §8**, §9, §10, §11, §12, §13, §14, §15, §16, §17 — so exactly four
sections (§5-§8, PDF pages 1024-1028) are absent, bracketed on both sides by sections that *are*
present (§4.7-4.8 and §9).

### 2. The AA rule's exact source location, verified against the PDF text

Extracted verbatim (pdftotext -layout) and cross-checked against a fresh pymupdf4llm pass:

- **§5. "The axiom system for bundled trees."** Introduces the base system `⊢_B` for bundled
  `ω`-trees: the usual PLTL axioms plus S5-style modal axioms C9-C15 for the path modality `A`,
  plus `C14` (atoms depend only on states) and `C15` (interaction between `A` and `X`). States
  Lemma 4 (`⊢_B` sound/weakly-complete for `⊨_B`, citing [Stirling 1992]) and notes this system is
  *incomplete* for the full CTL* validity `⊨_c`.
- **§6. "The limit closure axiom."** States the LC axiom schema and proves **Lemma 5** (LC is
  sound for `⊢_c`).
- **§7. "The auxiliary atoms rule."** States the motivation, **Definition 4** (the "functionally
  L+Q-expandable" side condition that governs which formulas `θ` may be used), the **AA rule**
  itself (derive `⊢ V` from `⊢ (θ → V)` under the side condition), and **Lemma 6** ("The AA rule is
  sound for `⊢_c`"), proved by contraposition.
- **§8. "The theorem."** **Definition 5** (`⊢_c` = `⊢_B` + LC + AA) and **Theorem 3** (`⊢_c` is
  sound and weakly complete for standard CTL* validity), which is the paper's main result and the
  reason §9 onward exists (the completeness proof for Theorem 3).

This exactly matches the BimodalLogic sub-index entry's existing `reason` field text ("...
limit-closure axiom LC (sec 6, Lemma 5) + Auxiliary Atoms rule (sec 7, Lemma 6)...") — that text
was written in anticipation of this exact gap being closed and requires no correction, only the
underlying sections to actually exist.

### 3. A naive full-document reconversion would regress existing quality — confirmed by a test run

The existing `sec01-sec10` files were migrated into `~/Projects/Literature/` from this repo's old
`specs/literature/` directory (task 710, 2026-06-14) and predate the current
`literature-convert.sh` pipeline; they use a clean house style — `## §N. <title>`-style headings,
an `**Abstract.**` block, and corrected Unicode (e.g. `§` itself, `⊢_L`, `⊨_B`) laid in by whatever
process originally produced them, despite some residual OCR-era artifacts (`C>1ia`, stray `u` for
`σ`) that are tolerated elsewhere in this corpus.

A scratch-directory test run (output never written into the live `Literature/` tree) of:

```
bash .claude/scripts/literature-convert.sh \
  /home/benjamin/Projects/Literature/sources/reynolds_2001/Reynolds_2001_Axiomatization_Full_CTL_star.pdf \
  <scratch_dir>
```

used engine `pymupdf4llm` and reported `Quality gate: PASSED` (headings=5-6, words=24789) — but
the actual output wraps nearly every paragraph in spurious `**bold**` markup, detects only 5-6
headings against the paper's 17 real sections (most `§N.` markers are not promoted to markdown
headings at all), and triggered a Tesseract OCR fallback on page 0 (`"Using Tesseract for OCR
processing"`) for what is a born-digital, non-scanned title page. The quality gate (which checks
column-interleaving, ligatures, hyphen-linebreaks, and printable-character ratio) does not check
for this bolding/heading-sparsity defect, so `PASSED` here is not a house-style-parity signal.

The §5-§8 *text itself* is fully present and legible in this test output (verified: Definition 4,
Lemma 5, Lemma 6, Theorem 3, the full AA rule statement all appear correctly), so the content is
recoverable from this engine — but the formatting is not fit to drop in as-is next to the existing
sections without hand-fitting to match their heading/emphasis conventions.

**Conclusion**: do not regenerate the whole 17-section document. Extract only the §5-§8 span,
hand-fit it (de-bold, promote `§N. <first clause>` runs to `##` headings matching the neighbors'
exact style, e.g. `sec04`'s `## §9. Completeness preliminaries. In what follows we have fixed...`)
and leave `sec01-03` and the current `sec04-10` content untouched.

### 4. The corpus's actual chunking convention is one chunk per §-section, not `literature-chunk.sh`'s token budget

`literature-chunk.sh`'s own header documents a 512-token target with a 1024-token hard cap for
atomic (Theorem/Proof/Definition-bearing) blocks, and a chunk-ID formula:

```
chunk_id = sha256(f"{doc_id}\x00{section_path}\x00{content[:64]}").hexdigest()[:16]
```
(`literature-chunk.sh` lines 20, 97-101; token estimate elsewhere in the same tooling family is
`len(text) // 4`, i.e. chars/4, not a word-count heuristic.)

But the *existing* `reynolds_2001` chunks ignore that budget entirely: `chunks.json`'s own
`token_count` field shows `§9. Completeness Preliminaries` at 3894 tokens and even the shortest
section, `§14.3. Hue Scheduling`, at 862 tokens — both far above 512 and the latter comfortably
under 1024 only because it happens to be short, not because anything subdivided it. The
established convention for this document is **one chunk per paper `§`-section, regardless of
size**, which is consistent with how this chapter-structured corpus is organized elsewhere (see
the `gabbay_1994`/`blackburn_2002` entries in the task's literature briefing, which are similarly
chunked at `§N.M` granularity). A rough char/4 estimate of the raw §5-§8 text puts them at ~560,
~470, ~1510, and ~245 tokens respectively — §7 (the AA rule, the longest of the four) exceeds the
nominal 1024 cap, but that is fine under this document's actual, already-precedented convention;
it should **not** be split into two chunks to satisfy a budget this document doesn't follow.

This means the implementation does not need to invoke `literature-chunk.sh` at all (which would
re-chunk/renumber the *entire* document fresh, reintroducing the quality risk from Finding 3).
Hand-authoring 4 new `chunks.json` entries using the documented chunk-ID formula, in the existing
file's own style, is both sufficient and lower-risk.

### 5. `literature-build-index.sh` only needs a valid `chunks.json`, not `literature-chunk.sh`'s own output shape

Reading `literature-build-index.sh`'s manifest-consumption logic: it discovers every
`chunks.json` under the target directory (excluding dot-prefixed subdirectories) and resolves
each chunk's content via that entry's own `source_path`, relative to the manifest's directory. It
does **not** require `literature-chunk.sh`'s own `chunk_NNNN.md` naming convention — the existing
`secNN_*.md` naming already works today, confirming hand-authored chunks using the same shape will
index correctly with no special-casing.

### 6. Index-rebuild scope: global only, no local DB in this repo

`literature-search.sh` queries `specs/literature/.literature.db` (local) first, then falls back to
`~/Projects/Literature/.literature.db` (global). This repo's `specs/literature/` directory is
explicitly **deprecated** (`specs/literature/DEPRECATED.md`, task 710, 2026-06-14) and holds no
`.literature.db` at all — confirmed by directory listing. So:

- Live `literature-search.sh "auxiliary atoms"` queries today fall straight through to the global
  DB (confirmed: results come from documents like `bacon_a_case_for_higher_order_metaphysics`,
  `baier_katoen_2008`, etc. — global-corpus-only entries per the literature briefing's coverage
  delta — and `reynolds_2001` is absent from every result).
- The implementation only needs `bash .claude/scripts/literature-build-index.sh --global`
  after the chunk files change — a `--local` rebuild is a no-op here (no manifests to find) and
  not required.

### 7. `specs/literature-index.json`'s sub-index entry needs no structural change

Per `literature-index.md`'s documented schema, the per-repo sub-index is deliberately
reference-only (`doc_id` + curation notes resolved at runtime against the global index — no
cached chunk/token metadata). The current entry:

```json
{
  "doc_id": "reynolds_2001",
  "reason": "...limit-closure axiom LC (sec 6, Lemma 5) + Auxiliary Atoms rule (sec 7, Lemma 6)...",
  "added": "2026-09-18",
  "source": "task 559 literature preparation...",
  "citation_rule": "Cite by the paper's own section/lemma/axiom labels. Never cite md line numbers."
}
```

is already accurate (confirmed against Finding 2) and does not need its `reason`/`citation_rule`
text changed. "Refreshing" this entry for task 915's deliverable is best satisfied by a small,
dated addendum recording that the reindex closed the §5-§8 gap (`specs/**` is the primary
exemption zone for record-versioning language, so a dated note here is permitted), rather than
any schema-level edit — there is no separate per-chunk cache in this file to regenerate.

### 8. An unrelated, pre-existing staleness worth flagging (non-blocking)

The *global* `~/Projects/Literature/index.json` entry for `reynolds_2001` carries a static
`token_count: 32665`, while summing the current `chunks.json`'s own 10 `token_count` values gives
33419 — already stale by ~750 tokens before this task touches anything, and the task's literature
briefing separately displays "~66084 tokens" for this document (roughly double either figure, via
some other computation not traced here). This is a pre-existing inconsistency independent of
task 915's gap; the implementation phase may choose to refresh this field as a drive-by fix once
the new chunks exist (true sum will become ~33419 + ~2790 ≈ 36200), but it is not a blocker for
this task's own deliverable and chasing the "~66084" discrepancy further is out of scope here.

## Decisions

- **Scope the fix as a splice, not a reconversion.** Confirmed via a scratch-directory test run
  that the current `literature-convert.sh auto` pipeline produces lower house-style quality than
  the existing hand-curated sections; only the missing §5-§8 span should be newly authored, and
  `sec01-03`/current-`sec04-10` content must be left byte-for-byte untouched except for the
  renumbering shift described in Recommendations.
- **Do not invoke `literature-chunk.sh`.** The document's established convention (one chunk per
  §-section, independent of token budget) predates and diverges from that script's defaults;
  hand-authoring the 4 new `chunks.json` entries in the existing file's own style is the correct,
  lower-risk match to house convention, confirmed compatible with `literature-build-index.sh`'s
  actual manifest-consumption logic.
- **Rebuild only the global FTS5 index.** This repo has no local `.literature.db` to rebuild
  (`specs/literature/` is deprecated); `--global` alone is sufficient and `--local` is a no-op.
- **Leave `specs/literature-index.json`'s `reason`/`citation_rule` text as-is.** It already
  correctly anticipates §6/Lemma 5 and §7/Lemma 6; only an optional dated addendum is warranted.

## Recommendations

For the planning phase, the concrete implementation sequence is:

1. **Extract clean §5-§8 text.** Re-run `literature-convert.sh` (pymupdf4llm, `auto`) into a
   scratch directory (as done in this research) to obtain the full document text, then take only
   the §5-§8 span (bounded by "§5. The axiom system for bundled trees" ... through ... "§8. The
   theorem" / Theorem 3, immediately before "§9. Completeness preliminaries"). Hand-clean it to
   match the neighbor files' house style: strip the spurious `**bold**` wrapping, promote each
   `§N. <opening clause>` run to a `##` heading exactly as `sec03`/`sec04` already do, and restore
   the corpus's established Unicode conventions (`§`, `⊢_B`, `⊢_c`, `⊨_B`, `⊨_c`, `A`, `X`, `G`,
   `U`) by comparing against the `pdftotext -layout` extraction and this report's Finding 2
   quotations as a cross-check.
2. **Write 4 new per-section files and renumber the existing sequence.** Insert
   `sec04_axiom-system-bundled-trees.md` (§5), `sec05_limit-closure-axiom.md` (§6),
   `sec06_auxiliary-atoms-rule.md` (§7), `sec07_the-theorem.md` (§8) into
   `~/Projects/Literature/sources/reynolds_2001/`, and shift the current `sec04`-`sec10` to
   `sec08`-`sec14` (same content, `git mv` within the `Literature/` repo, filenames unchanged
   otherwise). Suggested `section_path`/`title` strings, matching the existing naming style
   (`"§4.7-4.8. Equivalence Results and Inequivalence"`):
   - `"§5. The Axiom System for Bundled Trees"`
   - `"§6. The Limit Closure Axiom"`
   - `"§7. The Auxiliary Atoms Rule"`
   - `"§8. The Theorem"`
3. **Splice 4 new `chunks.json` entries**, computing each `chunk_id` as
   `sha256(f"reynolds_2001\x00{section_path}\x00{content[:64]}").hexdigest()[:16]` (the exact
   formula `literature-chunk.sh` uses), with `level: 1`, `parent_chunk_id: null`,
   `cross_refs: []` (matching every existing entry — this field appears unpopulated throughout the
   current manifest), and `source_path` set to the new filenames above. Re-link the chain: the
   existing §4.7-4.8 entry's `next_chunk_id` must point to the new §5 chunk, the new §8 chunk's
   `next_chunk_id` must point to the (renumbered, content-unchanged) §9 chunk, and that §9 entry's
   `prev_chunk_id` must point to the new §8 chunk.
4. **Rebuild the global index**: `bash .claude/scripts/literature-build-index.sh --global`.
5. **Verify** with `bash .claude/scripts/literature-search.sh "auxiliary atoms"` and/or `"Lemma 6
   sound CTL"` — the right chunk (new §7) should now appear ranked near the top with `doc_id:
   reynolds_2001`. Also spot-check `--toc reynolds_2001` shows the full §1-§17 sequence with no
   gap.
6. **Add a dated addendum** to `specs/literature-index.json`'s `reynolds_2001` entry (e.g. a
   `"reindexed"` field or a short addition to `reason`) recording that §5-§8 are now present —
   `specs/**` is the primary exemption zone for this kind of dated record note.
7. **Optional drive-by**: refresh the stale `token_count: 32665` field in the global
   `~/Projects/Literature/index.json` entry to match the new chunk-sum total, since the
   implementation will already have the final per-chunk counts in hand.

## Risks & Mitigations

- **Risk**: hand-fitting §5-§8's markdown to match house style introduces a transcription error in
  a formula (e.g. the AA rule's side condition, Definition 4's quantifier structure). **Mitigation**:
  the implementation should diff its final §6/§7 text against this report's Finding 2 verbatim
  quotations (themselves cross-checked against two independent extractions: `pdftotext -layout`
  and `pymupdf4llm`) before committing.
- **Risk**: renumbering `sec04-sec10` to `sec08-sec14` without updating every `source_path`
  reference in `chunks.json` leaves the manifest pointing at stale filenames.
  **Mitigation**: update filenames and `chunks.json` `source_path` fields in the same commit, and
  sanity-check with `literature-build-index.sh --global`'s own file-existence handling (it logs
  rather than silently skips a missing `source_path`).
- **Risk**: forgetting that `~/Projects/Literature/` is a separate git repository from
  `BimodalLogic` — commits there follow that repo's own conventions, not this one's `task {N}:
  ...` convention. **Mitigation**: the implementation phase should commit the `Literature/` repo
  changes and the `BimodalLogic` `specs/literature-index.json` change as two separate commits in
  their respective repositories.

## Context Extension Recommendations

- **Topic**: splicing a missing section span into an already-converted, hand-curated literature
  document without regenerating the whole thing.
- **Gap**: `context/project/literature/patterns/literature-convert-mode.md` documents the
  whole-document conversion engine tiers, and `literature-chunk.sh`'s header documents
  whole-document token-budget chunking, but neither covers the narrower "this document already
  exists and is good; add N missing sections without touching the rest" workflow this task needed
  — including the house convention (confirmed here) that an older, pre-`literature-convert.sh`
  conversion may already deviate from `literature-chunk.sh`'s token budget, and that this is
  expected rather than a defect to fix.
- **Recommendation**: a short pattern doc (e.g.
  `context/project/literature/patterns/partial-document-splice.md`) capturing: (1) always test a
  fresh conversion in a scratch directory first and diff its heading/emphasis style against the
  existing neighbor chunks before trusting `Quality gate: PASSED` as a house-style signal; (2) the
  chunk-ID formula and the fact that `literature-build-index.sh` needs nothing more than a valid
  `chunks.json`; (3) the local-vs-global `.literature.db` fallback a per-repo task must account
  for before assuming a `--local` rebuild is needed.

## Appendix

### Search queries used

- `bash .claude/scripts/literature-search.sh "auxiliary atoms"` (confirmed no relevant hit; no
  `reynolds_2001` result at all)
- `pdftotext -layout <pdf> -` then `grep -n -i "auxiliary"` / `grep -n "^\s*?[0-9]\+\."` to locate
  all 17 `§N.` section headings and their line ranges
- Scratch-directory `literature-convert.sh` test run (`LITERATURE_CONVERTER` left at default
  `auto`) to assess conversion quality and confirm §5-§8 text recoverability

### References

- `/home/benjamin/Projects/Literature/sources/reynolds_2001/chunks.json` (10 existing chunk
  entries, read in full)
- `.claude/scripts/literature-convert.sh`, `literature-chunk.sh` (lines 20, 78-101),
  `literature-build-index.sh` (lines 60-160), `literature-search.sh` (lines 41-141)
- `.claude/context/project/literature/domain/literature-index.md` (sub-index schema)
- `specs/literature/DEPRECATED.md` (local literature directory deprecation notice)
- `/home/benjamin/Projects/Literature/index.json` entry for `reynolds_2001` (global metadata,
  `token_count` staleness noted in Finding 8)

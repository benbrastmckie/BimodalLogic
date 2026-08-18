# Implementation Plan: Task #460

- **Task**: 460 - Acquire a usable copy of Gabbay, Kurucz, Wolter and Zakharyaschev 2003 (Many-Dimensional Modal Logics)
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: Task 459 (COMPLETED)
- **Research Inputs**: specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/01_acquire-gabbay-2003-copy.md
- **Artifacts**: plans/01_ocr-and-ingest-gabbay-2003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The Zotero-stored PDF of Gabbay/Kurucz/Wolter/Zakharyaschev 2003 is born-digital (LaTeX ->
dvips -> Ghostscript 2003) with every font embedded as Type 3 / Custom encoding and no ToUnicode
CMap, so every text-layer reader — `pdftotext`, PyMuPDF, `pymupdf4llm` — produces
printable-but-semantically-wrong mojibake. This plan replaces the PDF's text layer by OCR
(`ocrmypdf --force-ocr -l eng`) into a NEW file, gates that output on a **hand-read semantic
review** rather than a printable-character ratio, and only then runs a normal
`literature-ingest.sh` against the OCR'd path. Definition of done: a `gabbay_kurucz_wolter_
zakharyaschev_2003_many_dimensional_modal_logics` entry exists in
`~/Projects/Literature/index.json`, its chunks are hand-verified readable, the FTS index returns
it, and the Zotero original is bit-identical to its pre-task state.

### Research Integration

Findings carried directly into this plan from `reports/01_acquire-gabbay-2003-copy.md`:

- Source PDF: `/home/benjamin/Documents/Zotero/storage/8YXTY5UA/Gabbay et al. - 2003 - Many-Dimensional Modal Logics Theory and Applications.pdf` — 742 pages, 6.2 MB, Zotero
  bibliographic key `XYYBJH2N`, attachment key `8YXTY5UA`.
- Diagnosis is confirmed firsthand: `pdffonts` shows `Type 3 / Custom / uni=no` on all ~180+
  fonts; whole-document `pdftotext` printable ratio is 78.5% and the text is scrambled.
- Tooling verified present and working: `ocrmypdf` 17.4.2, `tesseract` 5.5.2 (with `eng`),
  `pdftoppm`/poppler 25.10.0, PyMuPDF/`fitz` 1.27.2.3. `ghostscript`, `qpdf`, `unpaper`,
  `pngquant`, and `jbig2` are NOT on PATH — `ocrmypdf` ran to exit 0 without them, and any
  PDF page-slicing or merging in this plan must therefore use PyMuPDF, never `qpdf`/`gs`.
- 8-page scratch trial with `ocrmypdf --force-ocr -l eng --output-type pdf` reached 99.94–99.96%
  printable ratio with hand-verified coherent prose. Display/inline math retains transcription
  noise (`tesseract eng` is not a math-OCR engine) — accepted, but recorded as a standing
  limitation, not hidden.
- CRITICAL: the `/literature` converters all read the same broken font layer, so re-running
  ingest against the ORIGINAL under any `LITERATURE_CONVERTER` value reproduces the corruption.
  The fix must precede conversion.
- CRITICAL: `literature_quality_gate.py` checks column-interleaving, ligatures, hyphenation,
  NUL bytes, and a non-printable-Unicode-category ratio. **None of these detects
  printable-but-wrong text.** That is exactly why the earlier `LITERATURE_CONVERTER=pymupdf`
  attempt produced 2260 mojibake chunks that PASSED the gate and had to be manually purged. This
  plan therefore treats the pipeline gate as necessary-but-not-sufficient and interposes its own
  semantic gate (Phase 4) and post-ingest semantic verification (Phase 6).
- Ingest must be invoked as `literature-ingest.sh <path-to-OCR-output>`, NOT `--zotero XYYBJH2N`,
  because the Zotero key resolves back to the broken original.

Additional facts established while planning (verified firsthand against the deployed scripts and
live corpus state):

- `literature-ingest.sh` derives `doc_id` from the **input filename** (lowercase, non-alnum ->
  `_`). The OCR output filename therefore determines the corpus doc_id and must be chosen
  deliberately.
- If a `doc_id` already exists in `index.json`, ingest logs a warning and `rm -rf`s the existing
  doc directory. Verified: no such entry exists today (`many.?dimensional|kurucz` matches only
  `caleiro_2013` / `caleiro_2013_sec01`, a different work), so this is a clean first ingest.
- Live baselines at plan time: `~/Projects/Literature/index.json` has **361 entries**;
  `.literature.db` FTS tables are `chunks_data` / `chunks_fts` / `chunk_relations` /
  `document_metadata` (there is no table named `chunks`).
- `specs/literature/` in this repo carries a `DEPRECATED.md` superseding it with
  `~/Projects/Literature/`. Ingest must therefore run with `--no-local`.
- Backup naming precedent in the corpus is `index.json.bak-YYYYMMDD-HHMMSS-pre-{label}` (e.g.
  `index.json.bak-20260818-130156-pre-457`). This plan follows it with `-pre-460`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so `specs/ROADMAP.md` was not consulted
as roadmap input. Spot inspection confirms it contains no literature-corpus acquisition item this
task would advance; the task's provenance is task 457's SCOPE 8 acquisition gap, tracked in
`specs/TODO.md` rather than the roadmap. No roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Produce a text-extractable OCR'd copy of the full 742-page book at a NEW path, leaving the
  Zotero-managed original bit-identical.
- Gate that OCR output on hand-read semantic evidence from multiple strata of the book, recorded
  verbatim in a durable artifact, before any ingest is permitted.
- Ingest the OCR'd copy through the normal `literature-ingest.sh` path (plain file argument,
  `--no-local`), producing a corpus entry, chunks, and FTS coverage.
- Hand-verify post-ingest chunks are readable, and leave a tested rollback/purge procedure that
  restores the corpus to its exact pre-task state if they are not.
- Record the math-OCR fidelity limitation explicitly so downstream consumers (`/cite`, `--lit`
  grounding) do not trust OCR'd formulas verbatim.

**Non-Goals**:
- Obtaining a different or cleaner scan of the book. The research established this is not
  achievable from this environment (commercial Elsevier title, no open-access edition) and is not
  needed.
- Math-fidelity OCR (LaTeX/MathML reconstruction). No math-OCR engine is installed; residual
  formula noise is accepted and documented, not solved.
- Fixing `literature_quality_gate.py`'s blind spot to printable-but-wrong text. That is a real
  defect surfaced by the research, but it is a separate concern; this plan works around it with
  its own semantic gates and recommends a follow-up.
- **Any modification to `specs/literature-index.json`.** That file carries a pre-existing
  uncommitted 41-line addition from unrelated work which this task must not commit, stash, or
  revert; adding a sub-index entry would make it impossible to commit this task's work without
  also committing that foreign diff. Sub-index registration is deferred to a follow-up and is
  recorded as such in the summary.
- Committing, stashing, reverting, or otherwise tidying anything in `~/Projects/Literature`'s
  pre-existing dirty tree (34 porcelain entries at plan time, from unrelated prior work).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A bad OCR result is ingested because the pipeline's ratio gate passes it (the exact 2260-chunk precedent) | H | M | Phase 4 semantic gate is a hard blocker: ingest may not run until hand-read excerpts from every sampled stratum are recorded and judged PASS. Citing a printable ratio as the pass reason is explicitly forbidden. Phase 6 repeats the hand-read check on post-ingest chunks. |
| Full-book OCR (742 pages) is long-running and could be interrupted mid-run, losing all progress | M | M | Phase 2 OCRs in 8 page-range batches, each written to its own output file and skipped on re-run if already complete. Every finished batch is a durable checkpoint; resume costs at most one batch. |
| Zotero-managed original is modified or overwritten | H | L | Phase 1 records the original's sha256; Phases 3 and 7 re-assert it unchanged. `ocrmypdf` is only ever invoked with an output path distinct from the input, and batch slicing reads the original read-only. |
| Merged OCR output is silently short (dropped/failed pages) | H | L | Phase 3 asserts merged page count == 742 and that per-batch page counts sum to 742 before any downstream step. |
| Math-heavy pages OCR poorly and propagate wrong formulas into chunks used for citation | M | H | Known and accepted. Phase 4 samples math-heavy strata explicitly and records the observed noise; Phase 7 records the limitation in the summary so `/cite` and `--lit` consumers cross-check formulas against the printed book. Prose fidelity, not formula fidelity, is the acceptance bar. |
| Corpus left in a half-ingested or corrupted state | H | L | Phase 5 takes a timestamped `index.json` backup before ingest; the Rollback section gives an exact restore + `rm -rf` + FTS-rebuild sequence, verified by re-checking the 361-entry baseline. |
| Task work accidentally commits the pre-existing `specs/literature-index.json` diff or perturbs `~/Projects/Literature`'s dirty tree | M | M | Modifying `specs/literature-index.json` is a declared non-goal. Phase 1 snapshots both dirty trees; Phase 7 diffs against those snapshots and commits only `specs/460_*/` paths by explicit path. |
| An oddly-rotated, diagram-only, or scanned-plate page OCRs to noise | L | M | Phase 4's sampling deliberately spans front matter, body, math, bibliography, and index; Phase 3 records any batch whose sidecar is anomalously short for follow-up inspection. Isolated non-prose pages do not fail the gate; a prose stratum failing does. |

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

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase is
a gate on the next, and Phase 4 in particular is a hard blocker on Phase 5.

---

### Phase 1: Baseline capture and immutability preconditions [COMPLETED]

**Goal**: Record every pre-task value that later phases assert against, and establish the
witnesses that prove the Zotero original and the two pre-existing dirty trees were untouched.

**Tasks**:
- [x] Create the working directory `~/Documents/literature-staging/gabbay_2003/` (outside Zotero
      storage and outside `~/Projects/Literature`, so neither tree is perturbed). *(completed)*
- [x] Record `sha256sum` and `pdfinfo` page count of the Zotero original into
      `~/Documents/literature-staging/gabbay_2003/baseline.txt`. This sha256 is the immutability
      witness re-checked in Phases 3 and 7. *(completed: sha256=6b03d3f9...557794b, 742 pages confirmed)*
- [x] Record corpus baselines into the same file: `jq '.entries | length'
      ~/Projects/Literature/index.json` (expected 361), and row counts for `chunks_data` and
      `chunks_fts` from `~/Projects/Literature/.literature.db`. *(completed: 361 entries, 17736/17736 rows, matches expectation)*
- [x] Confirm no colliding doc_id: `jq -r '.entries[].doc_id' ~/Projects/Literature/index.json |
      grep -i 'many.\?dimensional\|kurucz'` returns only `caleiro_2013*` (a different work). If it
      returns anything else, STOP and re-plan — ingest would `rm -rf` an existing doc directory.
      *(completed: grep returned zero matches, not even caleiro_2013 -- stronger than the plan's
      expectation but confirms the same safety property: no colliding doc_id)*
- [x] Snapshot `git -C ~/Projects/Literature status --porcelain` to
      `baseline-literature-porcelain.txt` (expected 34 lines at plan time) — the reference for
      Phase 7's "only expected additions" check. *(completed: 34 lines, matches exactly)*
- [x] Snapshot this repo's pre-existing uncommitted diff: `git diff specs/literature-index.json >
      baseline-subindex.diff` (expected 41 insertions). Do NOT commit, stash, or revert it.
      *(completed: 41 insertions confirmed via git diff --stat)*
- [x] Re-verify tooling with `ocrmypdf --version`, `tesseract --version`, `tesseract --list-langs |
      grep -x eng`, `python3 -c 'import fitz; print(fitz.__doc__)'`. Record versions.
      *(completed: ocrmypdf 17.4.2, tesseract 5.5.2 with eng, PyMuPDF 1.27.2.3, all present)*
- [x] Compute and record the doc_id the chosen output filename will produce, by running the same
      derivation ingest uses: `echo "<basename-without-extension>" | tr '[:upper:]' '[:lower:]' |
      tr ' ' '_' | tr -cs '[:alnum:]_.-' '_'`. Target filename:
      `gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf`.
      *(completed: derived doc_id gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics,
      confirmed against literature-ingest.sh's actual derivation logic including trailing-underscore strip)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts specific baseline values (742 pages; 361 index entries;
34 porcelain lines; 41-line sub-index diff) measured at plan time. Each is a hypothesis: the
implementer MUST re-measure all four and record the observed values, treating the plan's numbers
as expectations to confirm, not facts to assume. A divergence in the entry count or the sub-index
diff size is a signal that another session mutated shared state — pause and re-read the current
state before proceeding rather than forcing the plan's numbers.

**Files to modify**:
- `~/Documents/literature-staging/gabbay_2003/baseline.txt` - new; all recorded baselines
- `~/Documents/literature-staging/gabbay_2003/baseline-literature-porcelain.txt` - new
- `~/Documents/literature-staging/gabbay_2003/baseline-subindex.diff` - new

**Verification**:
- `baseline.txt` exists and contains: original sha256, page count, index entry count, both FTS row
  counts, tool versions, and the derived doc_id.
- Both snapshot files exist and are non-empty.
- No file under `/home/benjamin/Documents/Zotero/` and no file under `~/Projects/Literature/` was
  written (confirm with `git -C ~/Projects/Literature status --porcelain | diff - baseline-literature-porcelain.txt`, which must be empty).

---

### Phase 2: Batched full-book OCR with per-batch checkpoints [COMPLETED]

**Goal**: Produce OCR'd text-layer PDFs covering all 742 pages, in resumable batches, without
ever writing to the Zotero original.

**Tasks**:
- [x] Slice the original into 8 page-range batches with PyMuPDF (`fitz`), read-only on the input:
      batches of ~93 pages (1-93, 94-186, ..., 652-742). Write slices to
      `~/Documents/literature-staging/gabbay_2003/batches/src_NN.pdf`. Do NOT use `qpdf` or `gs` —
      neither is installed. *(completed: 8 slices present, src_01..src_07=93 pages each, src_08=91 pages)*
- [x] For each batch NN, run:
      `ocrmypdf --force-ocr -l eng --output-type pdf --sidecar batches/ocr_NN.txt
      batches/src_NN.pdf batches/ocr_NN.pdf`
      The `--sidecar` text file is the input to the Phase 4 semantic gate and costs nothing extra.
      *(completed: all 8 ocr_NN.pdf + ocr_NN.txt present)*
- [x] Make the loop idempotent/resumable: skip any batch whose `ocr_NN.pdf` already exists AND
      whose page count equals its `src_NN.pdf` page count. A completed batch is a durable
      checkpoint; an interrupted run resumes by re-invoking the same loop. *(completed: driver used)*
- [x] Run the loop in the background (it is long-running: the 8-page trial took 3.9s with 5
      workers, extrapolating to roughly 10–20 minutes for 742 pages, but this is not a tight
      bound and image-heavy pages cost more). Poll for completion rather than blocking.
      *(completed: actual wall time ~29-32s per batch, ~4 minutes total, well under the 10-20 min
      extrapolation)*
- [x] Record per-batch: exit code, wall time, output page count, and sidecar character count into
      `ocr-batches.log`. Flag any batch whose sidecar is anomalously short relative to its page
      count for inspection in Phase 4. *(completed: all 8 batches logged exit=0; sidecar_chars range
      158995-190392, no batch anomalously short relative to its ~93-page size)*
- [x] Expect and ignore the per-page `"page already has text! - rasterizing text and running OCR
      anyway"` notice — that is `--force-ocr` correctly discarding the broken text layer.
      *(completed: notice observed throughout log as expected, correctly ignored)*

**Timing**: 1.5 hours (mostly unattended wall time)

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The 8-batch / ~93-page split and the 10–20 minute total runtime are
estimates, not measurements. The implementer confirms the split by checking that per-batch page
counts sum to exactly 742, and confirms runtime empirically from `ocr-batches.log`. If the first
batch runs dramatically slower than extrapolated, re-size the remaining batches rather than
assuming the estimate holds.

**Files to modify**:
- `~/Documents/literature-staging/gabbay_2003/batches/src_NN.pdf` (8 files) - new page slices
- `~/Documents/literature-staging/gabbay_2003/batches/ocr_NN.pdf` (8 files) - new OCR output
- `~/Documents/literature-staging/gabbay_2003/batches/ocr_NN.txt` (8 files) - new OCR sidecars
- `~/Documents/literature-staging/gabbay_2003/ocr-batches.log` - new run log

**Verification**:
- All 8 `ocr_NN.pdf` exist, each with exit code 0 recorded in `ocr-batches.log`.
- Per-batch OCR page counts equal their source-slice page counts, and sum to exactly 742.
- All 8 sidecars exist and are non-empty.
- `sha256sum` of the Zotero original still matches `baseline.txt`.

---

### Phase 3: Merge batches and structural verification [COMPLETED]

**Goal**: Assemble one OCR'd 742-page PDF at the final ingest-input path, and confirm structurally
that its text layer is genuinely different from the broken original's.

**Tasks**:
- [x] Merge `ocr_01.pdf` .. `ocr_08.pdf` in order with PyMuPDF (`Document.insert_pdf`) into
      `~/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf`.
      The filename is load-bearing: it determines the corpus `doc_id`. *(completed)*
- [x] Assert merged page count == 742. *(completed: 742 confirmed via PyMuPDF)*
- [x] Run `pdffonts` on the merged output and confirm the font picture changed — the OCR text
      layer must present a normal, Unicode-mappable font rather than the original's uniform
      `Type 3 / Custom / uni=no`. Record the observed output. *(completed: original = 41x Type 3
      Custom + 1x Type 1C Custom (uni=no); merged = 8x CID TrueType Identity-H, emb=yes sub=yes
      uni=yes -- structurally distinct as required)*
- [x] Run `pdftotext` on the merged output; compute the whole-document printable ratio and record
      it (expected >= 99%, versus the original's 78.5%). **Record this as a structural signal
      only** — it is explicitly NOT the acceptance criterion, and Phase 4's gate may not cite it.
      *(completed: 99.9461% (1376321/1377063 chars), recorded in baseline.txt as structural
      context only)*
- [x] Concatenate the 8 sidecars into `ocr-full.txt` for convenient Phase 4 sampling.
      *(completed: 1389152 bytes)*
- [x] Re-assert the Zotero original's sha256 against `baseline.txt`. *(completed: MATCH,
      6b03d3f9...557794b)*

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: The ">= 99% printable ratio" expectation is extrapolated from an 8-page
trial to 742 pages. The implementer measures the actual full-document value and records it. A
value materially below the trial's 99.94% is a signal to inspect which pages drag it down (via
per-batch sidecar ratios) before proceeding — but a value at or above it is NOT by itself grounds
to pass Phase 4.

**Files to modify**:
- `~/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf` - new merged OCR output (the ingest input)
- `~/Documents/literature-staging/gabbay_2003/ocr-full.txt` - new concatenated sidecar text
- `~/Documents/literature-staging/gabbay_2003/baseline.txt` - append structural measurements

**Verification**:
- Merged PDF exists, opens, and reports exactly 742 pages.
- `pdffonts` on the merged file no longer shows the uniform `Type 3 / Custom / uni=no` picture.
- Full-document printable ratio recorded (a number, not a pass/fail).
- Zotero original sha256 unchanged.

---

### Phase 4: SEMANTIC quality gate — hand-read sampled pages [COMPLETED]

**Goal**: Decide, on hand-read evidence rather than any automated ratio, whether the OCR output is
genuinely coherent text. This is the crux of the task: it is the mechanism that makes it
impossible to ingest a bad OCR result on a passing ratio alone.

**Tasks**:
- [x] Sample at least 8 pages spanning distinct strata of the book, chosen so no single failure
      mode can hide: (1) front matter — title/TOC/preface; (2) Chapter 1 running prose;
      (3) a mid-body page around p.300; (4) a math-heavy section page (the research used the Ch.3
      region around p.150); (5) a proof-dense page (theorem + proof body); (6) a bibliography
      page; (7) an index / back-matter page from the final batch; (8) one page chosen at random
      from the whole range. *(completed: pages 5, 20, 300, 150, 412, 699, 733, 449 -- the random
      page was chosen via a seeded `random.choice` over the unsampled range to avoid cherry-picking)*
- [x] For EACH sampled page, extract its text (`pdftotext -f N -l N` on the merged PDF, or the
      corresponding region of `ocr-full.txt`), **read it**, and record in the evidence artifact:
      the page number, a verbatim excerpt of at least 200 characters, and an explicit PASS/FAIL
      judgement with a one-to-three sentence justification. *(completed: see
      reports/02_ocr-semantic-gate-evidence.md, all 8 excerpts 249-555 chars)*
- [x] Judge each page against these stated criteria — all four, in prose, per page:
      (a) the tokens are real English and real technical vocabulary, not plausible-looking
      non-words; (b) sentences are grammatical and topically consistent with many-dimensional
      modal logic; (c) proper nouns and citations resolve to plausible real names (e.g.
      Zakharyaschev, Chagrov, Fagin) rather than letter salad; (d) the page's content is
      consistent with its position in the book (front matter reads as front matter, an index page
      reads as an index). *(completed: all four criteria applied per page in the evidence artifact)*
- [x] **Forbidden**: citing the printable-character ratio, the pipeline quality gate, or any
      automated metric as the reason a page or the gate PASSES. Metrics may be recorded as
      context; they may not be the justification. This prohibition exists because the ratio gate
      demonstrably passed 2260 mojibake chunks. *(completed: no PASS justification in the evidence
      artifact cites any automated metric)*
- [x] Apply the gate decision rule and record it explicitly:
      - Every **prose** stratum (1, 2, 3, 5, 6, 7, 8) must PASS. A single prose FAIL blocks ingest.
      - The **math-heavy** stratum (4) passes if its surrounding prose is coherent and the
        observed errors are confined to formula symbols; record the specific formula noise seen.
      - If the gate FAILS: mark this phase `[BLOCKED]`, write the failure into the evidence
        artifact, and STOP. Do not proceed to Phase 5 under any circumstances. Contingency options
        to report: retry OCR with different `ocrmypdf` settings (e.g. `--oversample`, a different
        `--optimize` level) on the failing strata; or escalate to the user that a genuinely
        different scan is required (the research established one is not obtainable from this
        environment, so this is a user-action escalation, not an agent retry).
      *(completed: gate decision PASS -- all 8 strata PASS, decision recorded in the evidence
      artifact's "Phase 4 Gate Decision" section)*
- [x] Commit the evidence artifact before Phase 5 runs, so the gate record exists independently of
      whether ingest later succeeds. *(completed: committed in this dispatch prior to Phase 5)*

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: "At least 8 pages across 8 strata" is a floor, not a ceiling, and the
specific page numbers suggested (p.300, the Ch.3 math region) are provisional — the implementer
locates actual representative pages in the merged output and records which pages were sampled and
why. If any batch was flagged anomalous in Phase 2, its region MUST be added as an additional
sampled stratum beyond the 8.

**Files to modify**:
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/02_ocr-semantic-gate-evidence.md` - new; per-page excerpts, judgements, and the recorded gate decision

**Verification**:
- Evidence artifact exists and contains one section per sampled page with a verbatim excerpt of
  >= 200 characters and an explicit PASS/FAIL plus justification.
- The gate decision line is present and states the rule applied and the outcome.
- No PASS justification anywhere in the artifact cites a printable ratio or the pipeline gate.
- If the decision is FAIL, the phase heading carries `[BLOCKED]` and Phase 5 has not started.

---

### Phase 5: Ingest the OCR'd copy through the normal pipeline [COMPLETED]

**Goal**: Run `literature-ingest.sh` against the OCR'd path so the book enters the corpus through
the standard route, with a pre-ingest backup that makes the operation reversible.

**Initial run BLOCKED, then RESOLVED via user-authorized exception**: Ingest ran and was rejected
by `literature-convert.sh`'s conversion quality gate: `sentence-boundary-glue: 19 zero-space
word/sentence-fusion transition(s) found (threshold 3)`. Full site-by-site analysis, sidecar
cross-check, physical page locations, and a good-faith retry-OCR-settings attempt are recorded in
`reports/03_phase5-fusion-site-analysis.md`. Summary of that analysis: all 19 sites are confined
to description-logic ∃-role-restriction notation (13, one ~10-page passage), a recurring
bibliography citation (2), and irreducible proof/formula noise (4) — zero prose corruption. Both
the `pymupdf4llm` extraction and the independent `ocrmypdf` sidecar (already hand-verified by
Phase 4) agree on every checked site, ruling out a `pymupdf4llm`-specific extraction bug. Retrying
OCR with `--oversample 400` and `--tesseract-pagesegmode 6` did not change the result; `eng+equ`
is not a selectable tesseract language. No honest, non-fabricating correction of this text gets
the fusion count below the gate's threshold of 3. Per the explicit constraint against weakening,
disabling, bypassing, or working around the quality gate, the phase was left `[BLOCKED]` and
escalated to the user rather than forced through — see `.orchestrator-handoff.json` for the
three escalation options recorded at that point.

The user explicitly authorized escalation option 1: a corrected markdown restoring the 13
well-evidenced `∃`-glyph sites and the 2 Medvedev citation-spacing sites (leaving the 4
irreducible sites untouched, unfabricated) was fed directly to `literature-chunk.sh`, then
`index.json` was updated atomically and `literature-build-index.sh --global` was run — bypassing
only `literature-convert.sh`'s automated re-extraction for this one document.
`literature_quality_gate.py`, `literature-convert.sh`, and `run_quality_gate()` were never
modified and remain byte-identical for every other corpus document. Full before/after audit
trail for all 15 corrections is recorded in `reports/03_phase5-fusion-site-analysis.md`'s
addendum. doc_id `gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics`, 758
chunks, `index.json` 361 -> 362 entries.

**Tasks**:
- [x] Confirm Phase 4's recorded gate decision is PASS. If it is not, this phase must not run. *(completed: PASS confirmed)*
- [x] Back up the global index following the corpus's own naming precedent:
      `cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-460`.
      Record the exact backup filename — the Rollback procedure needs it. *(completed: index.json.bak-20260818-145418-pre-460)*
- [ ] Re-record the immediately-pre-ingest index entry count and FTS row counts (they may have
      moved since Phase 1 if another session ran). *(deviation: skipped — ingest failed at the
      conversion quality gate before touching index.json/FTS; re-confirmed post-failure instead:
      361 entries, unchanged)*
- [x] Run: `bash .claude/scripts/literature-ingest.sh
      ~/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf --no-local`
      - Plain file argument, NOT `--zotero XYYBJH2N` (that key resolves to the broken original).
      - `--no-local` because `specs/literature/` is superseded per its own `DEPRECATED.md`.
      - Leave `LITERATURE_CONVERTER` unset (the default `auto` primary `pymupdf4llm` tier is
        correct now that the text layer is sound). Do not force `pymupdf`.
      *(completed: ran; REJECTED by the conversion quality gate — see below)*
- [x] Capture the full ingest output, including the `=== Ingestion Summary ===` block, to
      `ingest.log` in the staging directory. *(completed)*
- [x] Check for a `.rejected` sibling in the new doc directory. `literature-convert.sh` writes
      `{doc_id}.md.rejected` INSTEAD of `{doc_id}.md` on quality-gate failure (exit 3) — a
      `.rejected` file means conversion did not succeed, regardless of the ingest exit code.
      *(completed: ingest.sh's own temp dir was deleted on rejection per its cleanup path, so the
      live `.rejected` sibling did not persist; `literature-convert.sh` was re-run standalone
      against the identical PDF into a scratch directory to reproduce it byte-for-byte for
      inspection — see reports/03_phase5-fusion-site-analysis.md)*
- [x] Record the resulting doc_id, chunk count, and new index entry count. *(completed: doc_id
      would have been `gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics`;
      chunk count N/A (conversion never reached chunking); index entry count unchanged at 361 —
      ingest did not modify the corpus)*

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: The expected index entry count after ingest is 362 (361 + 1), and the
expected doc_id is `gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics`. Both
are hypotheses: the implementer confirms the actual doc_id from the ingest log and the actual
count from `jq '.entries | length'`, and reconciles any difference before proceeding. Chunk count
is deliberately not predicted.

**Files to modify**:
- `~/Projects/Literature/index.json` - one new entry appended by the pipeline
- `~/Projects/Literature/index.json.bak-{timestamp}-pre-460` - new backup
- `~/Projects/Literature/{doc_id}/` - new doc directory with `{doc_id}.md`, `chunk_NNNN.md`, `chunks.json`
- `~/Projects/Literature/.literature.db` - rebuilt by the pipeline
- `~/Documents/literature-staging/gabbay_2003/ingest.log` - new

**Verification**:
- Ingest exits 0 and its summary reports zero entries under "Files failed" and zero under
  "Files quality-gate-failed".
- No `{doc_id}.md.rejected` file exists in the new doc directory; `{doc_id}.md` does exist.
- `jq '.entries | length' ~/Projects/Literature/index.json` increased by exactly 1 versus the
  immediately-pre-ingest count, and an entry with the expected doc_id is present.
- `~/Projects/Literature/{doc_id}/` contains `chunks.json` and a non-zero number of `chunk_*.md`.
- The pre-460 backup file exists and its filename is recorded.

---

### Phase 6: Post-ingest semantic verification of chunks [COMPLETED]

**Goal**: Confirm by hand-reading that what actually landed in the corpus is readable — the ingest
succeeding is not evidence that the chunks are good, since the pipeline gate cannot see
printable-but-wrong text.

**Tasks**:
- [x] Sample at least 8 chunks spread across the full chunk range: the first chunk, the last
      chunk, chunks at roughly the 25%/50%/75% positions, at least two chunks whose content is
      math-heavy, and at least one bibliography or index chunk. *(completed: chunk_0001 (first),
      chunk_0758 (last/index), chunk_0190 (~25%), chunk_0379 (~50%), chunk_0569 (~75%), chunk_0068
      and chunk_0092 (math-heavy), chunk_0742 (bibliography) — 8 chunks total)*
- [x] For EACH sampled chunk, read it and record in the evidence artifact: the chunk filename, a
      verbatim excerpt of at least 200 characters, and a PASS/FAIL judgement against the same four
      criteria as Phase 4. Again, no automated metric may serve as the PASS justification.
      *(completed: all 8 chunks PASS, recorded in reports/02_ocr-semantic-gate-evidence.md's
      "Phase 6" section)*
- [x] Run a mojibake sweep across all chunks as a supporting signal (not as the gate): grep for the
      corruption signatures characteristic of the original broken encoding (long runs of
      consonant-only uppercase tokens, `\[\[`/`\\\\` clusters, the `¨«`-style leading sequences
      seen in the research report's page 20-25 sample). Record hit counts by chunk; investigate any
      chunk with a high density. *(completed: 0 bracket-cluster hits, 0 leading-diacritic hits, 349
      consonant-run hits across 115/758 chunks, all confirmed legitimate book-internal acronyms
      (CPDL, TSPF, NTPP, BRCC, CQDL, etc.), zero genuine corruption)*
- [x] Confirm retrievability end-to-end: run
      `bash .claude/scripts/literature-search.sh "many-dimensional modal logic"` (and one more
      query using a distinctive phrase read verbatim from a sampled chunk) and confirm the new
      doc_id appears in the ranked results. *(completed: both queries return the new doc_id;
      `--include-unverified` required since this entry has no `provenance_fidelity` field)*
- [x] Sanity-check chunk count against 742 pages — record the ratio and note whether it is
      plausible relative to comparable full-book entries in the corpus; a wildly low count implies
      dropped content. *(completed: 758 chunks / 742 pages = 1.02 chunks/page, ~471.5 tokens/page,
      judged plausible against chagrovzakharyaschev_1997_modallogic's ~343 tokens/chunk)*
- [x] If any prose chunk FAILS, or retrieval does not return the doc: mark this phase `[BLOCKED]`,
      execute the Rollback/Contingency procedure below in full, and record the outcome. Do not
      leave a failed ingest in the corpus. *(not triggered: all chunks PASSED, retrieval
      confirmed)*

**Timing**: 0.75 hours

**Depends on**: 5

**Verification Tier**: prose

**Scope Hypothesis**: "At least 8 chunks" is a floor and the position-based selection is
provisional; the implementer records which chunks were actually sampled and why. The mojibake
signature list is derived from one observed sample in the research report and is not exhaustive —
treat a zero hit count as weak evidence only, never as a substitute for the hand-reads.

**Files to modify**:
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/02_ocr-semantic-gate-evidence.md` - append a post-ingest chunk-verification section

**Verification**:
- Evidence artifact contains >= 8 post-ingest chunk sections, each with a >= 200-character
  verbatim excerpt and an explicit PASS/FAIL plus justification.
- Mojibake sweep hit counts recorded for all chunks.
- `literature-search.sh` returns the new doc_id for both queries, with the output recorded.
- Chunk count and its ratio to 742 pages recorded and judged plausible.

---

### Phase 7: Closeout — immutability audit, limitation record, scoped commit [COMPLETED]

**Goal**: Prove nothing forbidden was touched, record the standing limitations and the deferred
sub-index registration, and commit only this task's own artifacts.

**Reopened once (dispatch_seq 15)**: orchestrator verification after the first closeout found the
Phase 5b addendum's `index.json` entry was written in the legacy `chunks_dir`-only schema (the
same shape task 458 spent 7 phases migrating 12 other entries away from), making this the corpus's
4th `id: null` straggler. Corrected in place by following task 458's `migrate12_mutate.py`
convention exactly: 7 v2 fields added (`id`, `path`, `token_count`, `doc_type`, `source_format`,
`provenance_fidelity` = `unverified_conversion`, `schema_normalized_at`) plus a `title`/`authors`/
`year` bibliographic correction from `zotero-library.json`'s `Kurucz2003` record. Entry count held
at 362 throughout; FTS row count held at 18,494 throughout (metadata-only edit). Full before/after
audit trail in `reports/03_phase5-fusion-site-analysis.md`'s Addendum 2. The underlying pipeline
defect (`literature-ingest.sh` always writes the legacy schema) was recorded as
`INGEST_WRITES_LEGACY_SCHEMA` for a future task, not fixed here (out of scope; `.claude/**` is a
disposable deploy artifact of the `agent-system/**` source store). Phase 7 is re-closed below with
this correction folded in.

**Tasks**:
- [x] Re-assert the Zotero original's sha256 against `baseline.txt`. Any mismatch is a task
      failure requiring immediate escalation, not a repair. *(completed: sha256
      6b03d3f967e1bff33dad1a2b6f770039011b93410d789fb4e36031fc6557794b re-verified unchanged)*
- [x] Diff current `git -C ~/Projects/Literature status --porcelain` against
      `baseline-literature-porcelain.txt`. The ONLY acceptable new lines are the new `{doc_id}/`
      directory and the new `index.json.bak-*-pre-460` backup (`index.json` and `.literature.db`
      were already modified in the baseline). Confirm no baseline line disappeared — nothing in
      that pre-existing dirty tree may have been committed, stashed, or reverted. *(completed:
      diff shows exactly these 2 new lines and drops none of the 34 baseline lines)*
- [x] Confirm `git diff specs/literature-index.json` in this repo is byte-identical to
      `baseline-subindex.diff` — this task must leave that pre-existing uncommitted modification
      exactly as it found it, and must not have added a sub-index entry. *(completed: byte-for-byte
      identical, 52/52 lines, 0-line diff-of-diffs)*
- [x] Write the implementation summary at
      `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/summaries/01_ocr-and-ingest-gabbay-2003-summary.md`,
      recording: the OCR command and settings used, the resulting doc_id and chunk count, the
      Phase 4 and Phase 6 gate outcomes with pointers to the evidence artifact, the staging path
      of the OCR'd PDF (so it can be re-ingested or re-examined without re-running OCR), and
      three standing items —
      (a) **math-OCR limitation**: display and inline formulas carry transcription noise;
      `/cite` and `--lit` consumers must cross-check formula text against the printed book and
      must not quote OCR'd formulas verbatim;
      (b) **deferred sub-index registration**: `specs/literature-index.json` was deliberately not
      modified because of its pre-existing uncommitted diff — recommend a follow-up task to add an
      entry carrying the math-fidelity hazard note;
      (c) **quality-gate blind spot**: `literature_quality_gate.py` cannot detect
      printable-but-semantically-wrong text, which is why this task interposed manual semantic
      gates — recommend a follow-up to address the gate itself. *(completed: all three standing
      items present, plus two new follow-ups discovered during Phase 6 — the section_path
      heading-detection defect and the unset provenance_fidelity field)*
- [x] Commit in this repo by explicit path only: `git add
      specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/` then commit. Never `git add
      -A`, never `git add specs/`, and never stage `specs/literature-index.json`. *(completed:
      commit 60029bab1, `git show --stat HEAD` touches only the 4 expected files under
      specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/)*
- [x] Do not commit anything in `~/Projects/Literature` — that repo's tree is user-managed and was
      already dirty from unrelated work. *(completed: no commit made in that repo)*

**Timing**: 0.5 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: The expected porcelain delta is "exactly two new lines" (new doc directory,
new backup file). The implementer confirms the actual delta and, if extra lines appear, identifies
each one's origin before committing rather than accepting it as noise — an unexplained new line in
that tree may be another session's concurrent work that this task must leave alone.

**Files to modify**:
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/summaries/01_ocr-and-ingest-gabbay-2003-summary.md` - new

**Verification**:
- Zotero original sha256 matches Phase 1's recorded value.
- Porcelain delta contains only the two expected new entries and drops no baseline entry.
- `git diff specs/literature-index.json` is byte-identical to `baseline-subindex.diff`.
- Summary exists and contains all three standing items (a), (b), (c).
- `git show --stat HEAD` shows only paths under
  `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/`.

---

## Testing & Validation

- [x] Zotero original at `/home/benjamin/Documents/Zotero/storage/8YXTY5UA/...pdf` has an
      unchanged sha256 at Phase 3, Phase 7, and end of task. *(completed: re-verified
      6b03d3f9...557794b unchanged at every checkpoint)*
- [x] Merged OCR PDF has exactly 742 pages and a text layer whose fonts are no longer uniformly
      `Type 3 / Custom / uni=no`. *(completed: 742 pages, 8 CID TrueType/Identity-H emb=yes
      uni=yes fonts, per baseline.txt Phase 3 measurements)*
- [x] Full-document printable ratio of the OCR'd copy is recorded (structural context only, never
      cited as an acceptance reason). *(completed: 99.9461%, recorded in baseline.txt, never cited
      as PASS justification anywhere)*
- [x] Phase 4 evidence artifact contains >= 8 hand-read page sections with >= 200-character
      verbatim excerpts, explicit PASS/FAIL, and a stated gate decision — with no PASS justified
      by an automated metric. *(completed: 8 strata, all PASS)*
- [x] Ingest ran against the OCR'd file path (not `--zotero`), exited 0, produced no `.rejected`
      file, and left no entry in the summary's "Files failed" or "Files quality-gate-failed" lists.
      *(deviation: altered — the automated `literature-ingest.sh` invocation was in fact rejected
      by the conversion quality gate on 19 sites and DID produce a `.rejected` sibling (report 03).
      Per the user-authorized exception, the equivalent end state was instead reached by feeding a
      hand-corrected markdown directly to `literature-chunk.sh` + an atomic `index.json` update +
      `literature-build-index.sh --global`, bypassing only `literature-convert.sh`'s automated
      re-extraction for this one document. No `.rejected` file exists in the final doc directory;
      the corpus entry, chunks, and FTS coverage this criterion ultimately checks for are all
      present and verified below.)*
- [x] `~/Projects/Literature/index.json` gained exactly one entry, with the expected doc_id.
      *(completed: 361 -> 362, doc_id gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics
      confirmed present)*
- [x] Phase 6 evidence artifact contains >= 8 hand-read chunk sections with >= 200-character
      verbatim excerpts and explicit PASS/FAIL. *(completed: 8 chunks, all PASS)*
- [x] Mojibake signature sweep across all new chunks recorded, with any high-density chunk
      investigated. *(completed: 349 hits across 115/758 chunks swept and individually confirmed
      legitimate book-internal acronyms; 0 genuine corruption)*
- [x] `literature-search.sh` returns the new doc_id for both a topical query and a verbatim-phrase
      query drawn from a sampled chunk. *(completed: both queries returned the doc_id)*
- [x] `git diff specs/literature-index.json` is byte-identical to the Phase 1 baseline diff.
      *(completed: 52/52 lines, 0-line diff-of-diffs)*
- [x] `git -C ~/Projects/Literature status --porcelain` differs from the Phase 1 baseline only by
      the new doc directory and the new `-pre-460` backup; no baseline line was removed.
      *(completed: confirmed, exactly 2 new lines, 0 dropped)*
- [x] The commit in this repo touches only paths under
      `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/`. *(completed: commit
      60029bab1, `git show --stat HEAD` confirms 4 files, all under that path)*

## Artifacts & Outputs

- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/plans/01_ocr-and-ingest-gabbay-2003.md` (this file)
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/02_ocr-semantic-gate-evidence.md` (pre-ingest page evidence + post-ingest chunk evidence)
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/summaries/01_ocr-and-ingest-gabbay-2003-summary.md`
- `~/Documents/literature-staging/gabbay_2003/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics.pdf` (the OCR'd copy; retained so re-ingest never requires re-running OCR)
- `~/Documents/literature-staging/gabbay_2003/` supporting files: `baseline.txt`, `baseline-literature-porcelain.txt`, `baseline-subindex.diff`, `batches/`, `ocr-full.txt`, `ocr-batches.log`, `ingest.log`
- `~/Projects/Literature/{doc_id}/` corpus entry (markdown + chunks + `chunks.json`), one new `index.json` entry, and a rebuilt `.literature.db`

## Rollback/Contingency

**If the Phase 4 semantic gate fails**: nothing has entered the corpus. Stop, mark the phase
`[BLOCKED]`, record the failing strata and excerpts, and report the contingency options (retry OCR
with different `ocrmypdf` settings on the failing regions; or escalate to the user that a
genuinely different scan is needed — the research established one is not obtainable from this
environment). Do not run Phase 5.

**If Phase 6 finds unreadable chunks** (the 2260-chunk precedent recurring), purge in this order:

1. `rm -rf ~/Projects/Literature/{doc_id}/`
2. `cp ~/Projects/Literature/index.json.bak-{timestamp}-pre-460 ~/Projects/Literature/index.json`
   (the exact backup filename recorded in Phase 5). Do NOT hand-edit `index.json`.
3. `bash .claude/scripts/literature-build-index.sh --global` to rebuild `.literature.db` from the
   chunk files that remain on disk. The database is ephemeral and always rebuildable from chunks,
   so this restores FTS state without any surgical row deletion.
4. Verify the restore: `jq '.entries | length' ~/Projects/Literature/index.json` equals the Phase 1
   baseline (361 at plan time); `jq -r '.entries[].doc_id'` no longer contains the doc_id; and
   `literature-search.sh` on a distinctive phrase from the book returns no hit for it.
5. Confirm `git -C ~/Projects/Literature status --porcelain` is back to the Phase 1 baseline plus
   only the `-pre-460` backup file (leave the backup in place — it matches the corpus's existing
   `.bak-*` precedent and is not this task's to clean up).
6. Keep the OCR'd PDF in staging for diagnosis. Do not re-ingest it without a fresh, passing
   semantic gate.

**Not permitted under any contingency**: modifying or replacing the Zotero-managed original;
committing, stashing, or reverting `~/Projects/Literature`'s pre-existing dirty tree; committing,
stashing, or reverting this repo's pre-existing `specs/literature-index.json` modification;
`git add -A` or `git commit -am` in either repository.

# Research Report: Task #460

**Task**: 460 - Acquire a text-extractable copy of Gabbay/Kurucz et al., "Many-Dimensional Modal Logics: Theory and Applications" (2003)
**Started**: 2026-08-18T21:32:34Z
**Completed**: 2026-08-18T22:10:00Z
**Effort**: ~1 session (investigation + small OCR trial, no ingest)
**Dependencies**: None
**Sources/Inputs**: Zotero SQLite library (read-only copy), local PDF file, `pdfinfo`/`pdffonts`/`pdftotext` (poppler), `ocrmypdf`/`tesseract` (system tools), `.claude/scripts/literature-*.sh` and `literature_quality_gate.py` (pipeline source, read-only), one WebSearch
**Artifacts**: - this report only (no corpus/index mutation)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Root cause confirmed firsthand**: the Zotero copy of this book is a **born-digital PDF produced via LaTeX -> dvips -> Ghostscript in 2003**, not a scanned image. Every text font in it is embedded as **Type 3 with a "Custom" encoding and no ToUnicode CMap** (`pdffonts` confirms `uni=no` on all ~180+ fonts). `pdftotext` therefore emits visually-plausible but semantically wrong ASCII — this is glyph-index-as-character-code corruption, not a raster/scan problem.
- **OCR is viable and was trial-verified**, contrary to the intuition that "OCR only helps for scans." Because the PDF pages render correctly as vector/bitmap glyph shapes (Type 3 procedures draw the right shapes even though their character-code mapping is broken), `ocrmypdf --force-ocr` can rasterize each page and re-recognize it visually, discarding the broken text layer entirely and writing a fresh, correctly-encoded one.
- **Trial result (5 prose pages + 3 math-heavy pages, in `/tmp` scratch only, not ingested)**: printable-character ratio rose from **78.5% (whole-book baseline, corroborating the reported 69.5%) to 99.94–99.96%**, and the extracted text is **fully human-readable, coherent, and topically correct** prose (verified by hand-read excerpt matching known content of the book). Inline/display math formulas still show residual transcription noise (expected — `tesseract`'s `eng` model is not a math-OCR model), but this is qualitatively a different, much smaller problem than the current total corruption.
- **All required tooling is already installed**: `ocrmypdf 17.4.2`, `tesseract 5.5.2` with `eng` (and 128 other) language packs, `pdftoppm`/`poppler 25.10.0`, `pymupdf`/`fitz 1.27.2.3`. No installation step is needed.
- **A cleaner alternative scan is not something I can obtain from this environment.** The book is a commercial Elsevier title (*Studies in Logic and the Foundations of Mathematics*, Vol. 148, ISBN 9780444508263, xiv+747pp) with no open-access edition; legitimate routes (library/interlibrary loan, an institutional PDF, or a different personal scan) require user action outside this session. The OCR route above does not depend on that and is the recommended path.
- **Critical pipeline finding**: the normal `/literature` ingest path's PyMuPDF-based converters (`pymupdf4llm` primary tier, `pymupdf` fallback tier) read text from the **same broken font/encoding layer** that `pdftotext` reads. Re-running ingest against the *original* PDF — with *any* `LITERATURE_CONVERTER` setting, not just `pymupdf` — will reproduce the same corruption, because the corruption is upstream of converter choice. The fix has to replace the PDF's text layer (OCR) *before* conversion, not change which converter reads it.

## Context & Scope

Task 460 asks for research only: locate and characterize the Zotero PDF's extraction failure, verify what OCR tooling exists, run a small scratch-only OCR trial and measure its quality, assess whether a cleaner copy is obtainable, and describe what the `/literature` ingest path expects as input for a follow-up implementation task. No ingestion, no `~/Projects/Literature/index.json` mutation, no full-book OCR was performed.

## Findings

### 1. Locating and characterizing the Zotero PDF

Zotero's live `zotero.sqlite` was locked (Zotero running), so I worked from a read-only copy in scratch (`/tmp/.../scratchpad/zotero_copy.sqlite`) to look up the item.

- Bibliographic item: itemID `4554`, Zotero item key **`XYYBJH2N`**, title "Many-Dimensional Modal Logics: Theory and Applications" (this is presumably the record the task calls "Kurucz2003" — that string does not appear anywhere in `~/Projects/Literature/index.json`, confirming the item has never been ingested).
- PDF attachment: itemID `4556`, attachment key **`8YXTY5UA`**, stored at:
  ```
  /home/benjamin/Documents/Zotero/storage/8YXTY5UA/Gabbay et al. - 2003 - Many-Dimensional Modal Logics Theory and Applications.pdf
  ```
  6.2 MB, 742 pages, A4.

`pdfinfo` on this file:
```
Title:           0.dvi
Creator:         dvips(k) 5.86 Copyright 1999 Radical Eye Software
Producer:        AFPL Ghostscript 8.0
CreationDate:    Sun Jan 26 02:09:47 2003 PST
PDF version:     1.4
Pages:           742
```
This is the fingerprint of a **LaTeX book typeset and exported via `dvips`+Ghostscript** — i.e., born-digital vector text, not a scan.

`pdffonts` output (first ~30 of ~180+ fonts) shows the mechanism precisely:
```
name    type      encoding   emb sub uni
R11     Type 3    Custom     yes  no  no
R294    Type 3    Custom     yes  no  no
...
FW      Type 1C   Custom     yes  no  no
```
Every font is `Type 3` (bitmap/procedure glyphs drawn by tiny embedded PostScript programs) with a **`Custom` encoding and `uni=no`** (no Unicode/ToUnicode mapping at all). This is the classic old-`dvips` PDF failure mode: each font's character codes are whatever arbitrary numbering the TeX DVI driver assigned, and without a ToUnicode CMap, any text-extraction tool (`pdftotext`, PyMuPDF, `pdfplumber`, etc.) can only guess at a code-to-Unicode mapping — poppler falls back to something like WinAnsi/Standard heuristics, which is exactly why the extracted text is visually plausible-looking ASCII that is actually wrong.

Firsthand confirmation of the failure, page 20–25 sample via `pdftotext`:
```
¨«JR\\[[gU DGFSDFFyWG\AD\F\IFI
B D[ cD[[IRDC?F?[cBA[IRJU ??gFR\EBFFWRDBCFRDA\DCAR EEDEGRFcABR\CDfD[AJGgRGIgRT
...
```
— scrambled, not real words. Printable-character ratio on this 5-page sample: **90.8%** (i.e., mojibake made of *printable* wrong characters, not control-character garbage — which is exactly why it can slip past a naive printable-ratio gate; see Pipeline section below).

Full-document `pdftotext` extraction (all 742 pages, 1,494,508 characters): printable ratio **78.5%**, corroborating the task's reported ~69.5% figure (measurement method/tool likely differs slightly — poppler version, whitespace handling — but the order of magnitude and conclusion match: this is a whole-book failure, not isolated pages).

**Conclusion for item 1**: This is a **text PDF with a broken/custom font encoding (no ToUnicode CMap)**, not a scanned-image PDF. The correct remedy category is "re-derive the text via visual OCR of the rendered pages" (since the glyphs render correctly, only their character-code mapping is broken) — a raster/scan-only assumption would have wrongly ruled this out, but it is in fact exactly the situation where `ocrmypdf --force-ocr` is designed to help: it rasterizes each page (ignoring the existing, in this case broken, text layer) and OCRs the rendered image.

### 2. OCR tooling verification (measured, not assumed)

All commands were actually run, not just checked for existence:

| Tool | Version | Status |
|---|---|---|
| `ocrmypdf` | 17.4.2 | Installed (`/run/current-system/sw/bin/ocrmypdf`), ran successfully end-to-end |
| `tesseract` | 5.5.2 (leptonica 1.87.0) | Installed, ran successfully |
| `tesseract` language data | 129 languages available in `/nix/store/.../tessdata/`, including `eng` (needed here) and `equ` (Tesseract's built-in "equation region" detector — not a full math-OCR engine, but present) | Installed |
| `pdftoppm` / poppler | 25.10.0 | Installed, used internally by `ocrmypdf` for rasterization |
| `pymupdf` (`fitz`) | 1.27.2.3 | Installed (Python), used here only to slice small page ranges for the trial, and used by the `/literature` pipeline for conversion |
| `ghostscript` (`gs`) | **not on PATH** | Not found |
| `qpdf` | **not on PATH** | Not found |
| `unpaper`, `pngquant`, `jbig2` (ocrmypdf optional extras) | **not found** | Not installed, but these are optional image-cleanup/compression add-ons only — `ocrmypdf` ran successfully and produced valid output without them |

`ocrmypdf --force-ocr` completed with exit code 0 on both trial files despite the missing optional tools, so **the core OCR path is fully functional on this machine today**. (If a future full-book run wants smaller output via JBIG2 image compression, `jbig2` would need to be added — not required for text-quality purposes.)

### 3. Small OCR trial (scratch only, not ingested)

Two trial PDFs were built with PyMuPDF by slicing pages out of the original (page numbers 0-indexed in code, so "pages 20–24" and "pages 150–152" 1-indexed), written only to
`/tmp/claude-1000/.../scratchpad/trial_sample.pdf` and `trial_math.pdf` — **outside `~/Projects/Literature/` and outside `specs/literature/`, nothing touched the corpus**.

**Command used** (identical to what a real remediation would run, just on a small slice):
```
ocrmypdf --force-ocr -l eng --output-type pdf trial_sample.pdf trial_sample_ocr.pdf
```
Output: `ocrmypdf` logged `"page already has text! - rasterizing text and running OCR anyway"` for every page (expected — it's telling us it detected the existing broken text layer and, because of `--force-ocr`, discarded it and OCR'd the rendered image instead, which is exactly the desired behavior here). Exit code 0. Wall time for 5 pages: **3.9s** (5 parallel workers) — full-book (742 pages) is extrapolated at very roughly **10–20 minutes**, though real per-page cost varies with image complexity and this is not a tight bound.

**Prose-page trial (5 pages, Chapter 1 intro material)**:
- Printable-character ratio: **99.96%** (11,393 chars, 11,388 printable) — up from ~90.8% pre-OCR on the same slice.
- Hand-read excerpt (verbatim from `pdftotext` on the OCR'd output):
  > "Now, returning to modal logic, we see that this semantical definition of Cl cannot be extended to the modal language in a straightforward way. The apparent reason is that the modal operators are not truth-functional: the truth-value of a formula of the form □φ can depend not only on whether φ is true or false. For example, we most likely agree that the proposition 'it is necessary that 2 × 2 = 4' is true, while 'it is necessary that NATO bombs Belgrade' is undoubtedly false... As the well-known soundness and completeness theorem of classical propositional logic says, the logic defined by this calculus coincides with Cl (see e.g., Chagrov and Zakharyaschev 1997, ...)"

  This is coherent, grammatically correct, and topically consistent with the book (the self-citation to "Chagrov and Zakharyaschev 1997" is itself internally consistent — Zakharyaschev is a co-author of this book). Axiom lists (A1)–(A10) and inference-rule definitions (Modus Ponens, Substitution) are recovered essentially verbatim, modulo minor symbol-rendering noise on the propositional-variable subscripts.

**Math-heavy-page trial (3 pages, deeper technical section, Ch. 3)**:
- Printable-character ratio: **99.94%** (5,259 chars, 5,256 printable).
- Prose portions are equally clean; a numbered theorem statement and surrounding discussion of "temporal epistemic logic," "synchronous systems," and Fagin et al. 1995 are correctly recovered.
- **Caveat, stated honestly**: inline/display math formulas show residual transcription errors, e.g. a formula intended as something like `◇p1 → □(...)` came out as `Op1 — D1(DF_J_\/ QFDF_J_)`. This is expected: `tesseract`'s `eng` traineddata is a natural-language OCR model, not a math-formula OCR model (no LaTeX/MathML reconstruction). The printable-ratio metric doesn't catch this because the wrong output is still made of printable ASCII — but qualitatively this is a *localized, math-symbol-only* residual error, not the *systemic, every-character* corruption of the current file. Prose (the majority of the book's running text) is recovered essentially cleanly; display equations and heavy inline math notation will need either acceptance of some noise, manual spot-correction, or a dedicated math-OCR tool (not installed here, e.g. `pix2tex`/`Mathpix`-style tools) if higher math fidelity is required later.

**Trial conclusion**: OCR via `ocrmypdf --force-ocr -l eng` is the concrete, working remedy. It should be run once on the *full* 742-page original (not attempted in this research-only task), producing a new PDF with a correct embedded text layer, which then becomes the input to the normal `/literature` ingest path.

### 4. Is a cleaner copy obtainable?

One web search confirmed bibliographic facts but, as expected for a commercial academic monograph, turned up no open-access full text:

- Publisher: Elsevier, series *Studies in Logic and the Foundations of Mathematics*, Vol. 148, ISBN 9780444508263, xiv+747pp — a paid title with a Google Books preview (snippet-only, not a downloadable clean full text) and library-catalogue/PhilPapers/ResearchGate listing pages (metadata only, no full-text PDF hosted there).
- I did not find, and would not chase further via this session, any freely redistributable alternate scan — that is consistent with this being an unmodified, actively-sold Elsevier book still under copyright, not an out-of-print or author-hosted work.

**Honest assessment**: from this environment, I cannot obtain a different/cleaner scan. Legitimate routes to a better copy are all outside what an agent session can execute:
1. **User already owns the file** — the OCR remediation in Section 3 above requires no new copy at all and is the recommended path regardless.
2. If a genuinely different scan is wanted (e.g., because OCR math fidelity proves insufficient for some later formal-verification task), that would require the user to source one via institutional library access, interlibrary loan, or another personal copy — none of which this agent can initiate.

**Recommendation**: do not block on route 2. Route 1 (OCR the existing file) already clears the "text-extractable" bar this task set (printable ratio 78.5% → 99.9%+, human-readable prose) and needs no external acquisition step.

### 5. What the normal `/literature` ingest path expects (target for a follow-up implementation task)

Read `.claude/scripts/literature-ingest.sh`, `literature-convert.sh`, and `literature_quality_gate.py` (read-only; per `source-store-deploy-boundary.md` these are a *deployed* copy of `agent-system/extensions/literature/**` — noted for awareness, not edited).

- **Ingest entry point**: `literature-ingest.sh <path-to-pdf-or-djvu>` (a single file or a directory of them) **or** `literature-ingest.sh --zotero <key>`, which resolves the key against a separate `zotero-library.json` export (not the live `zotero.sqlite`) to find a `pdf_path`/`file`/`attachment` field.
  - **Important for the follow-up implementation phase**: using `--zotero XYYBJH2N` (or whatever key `zotero-library.json` uses) would resolve back to the *original, broken* PDF in Zotero storage. The follow-up task should instead run `literature-ingest.sh <path-to-OCR'd-copy>` as a plain file argument, pointing at the OCR output (e.g. staged somewhere under `~/Projects/Literature/` or a scratch path), **not** re-derive it from the Zotero key — this sidesteps ever needing to overwrite/replace the file inside Zotero's own storage.
- **Pipeline stages**: resolve source -> `literature-convert.sh` (PDF/DJVU -> markdown) -> `literature-chunk.sh` (markdown -> chunks) -> update global `index.json` -> rebuild `.literature.db` -> optional local copy into `specs/literature/`.
- **Conversion engine tiers** (`literature-convert.sh`): primary `pymupdf4llm.to_markdown()`, automatic fallback to a zero-dependency PyMuPDF column-clustering extractor, with `pdftotext` as an explicit manual-only last resort. **All of these read the PDF's embedded text/font layer** — none of them do their own OCR. This is the key mechanical reason the earlier `LITERATURE_CONVERTER=pymupdf` attempt produced 2,260 chunks of mojibake: PyMuPDF was reading through the *same* broken Type 3/no-ToUnicode font encoding as `pdftotext` does. **Re-running ingest against the original file, with any converter setting, will reproduce the same corruption** — the fix has to happen before conversion (replace the text layer via OCR), not by picking a different converter.
- **Quality gate** (`literature_quality_gate.py`, imported by `literature-convert.sh`): checks column-interleaving, sentence-boundary word-gluing, unresolved ligatures, unresolved hyphenation, NUL-byte control characters (zero-tolerance), and a broader non-printable-Unicode-category `printable_ratio` (control/surrogate/private-use/unassigned categories — *not* zero-tolerance, per that module's own calibration notes, because ~half the live corpus legitimately uses Private-Use-Area codepoints as a math-symbol fallback under partial ToUnicode maps). **None of these checks detect "printable-but-semantically-wrong" text** — a broken CMap that maps to *other valid, printable* Unicode codepoints (as this book's does) is invisible to every one of these checks, which is exactly how 2,260 garbled chunks passed the gate previously. This is a real limitation of the current gate worth flagging to whoever plans the follow-up implementation task, though fixing the gate itself is out of scope for task 460.
- **Expected clean input for a follow-up implementation task**: a PDF (or DJVU) whose embedded text layer is genuinely extractable — i.e., either a properly-encoded born-digital PDF, or (this book's case) a PDF whose text layer has been replaced by OCR output with standard encoding/ToUnicode, such as the `ocrmypdf --force-ocr -l eng` output demonstrated in Section 3. Given that, the existing `pymupdf4llm`-primary conversion tier should work normally with no special-casing.

## Decisions

- **No ingestion or index mutation was performed**, per task instructions — this report only documents findings and a viable remediation path.
- **Recommended remediation for the follow-up implementation task**: run `ocrmypdf --force-ocr -l eng --output-type pdf` on the *full* original 742-page file, writing to a new path (not overwriting the Zotero-managed original), then feed that output path directly (not via `--zotero`) into `literature-ingest.sh`.
- **Do not attempt to source an alternate scan as a precondition** — it is not obtainable from this environment and is not needed, since OCR alone already meets the "text-extractable" bar.

## Risks & Mitigations

- **Risk**: OCR of the full 742-page book takes meaningfully longer than the 5–8 page trial and could hit an unexpected page (e.g., a diagram-only or oddly-rotated page) that OCRs poorly. **Mitigation**: the follow-up implementation task should spot-check a handful of pages spread through the OCR'd output (front matter, a chapter start, an index/bibliography page) before ingesting, the same way this trial did, rather than assuming uniform quality across all 742 pages.
- **Risk**: math-heavy display formulas will have residual OCR noise (demonstrated in Section 3), which could propagate into chunks used for citation verification (`/cite`) or literature-grounded implementation. **Mitigation**: flag this as a known limitation in the eventual ingest; downstream consumers relying on exact formula text should cross-check against the printed book or a secondary source rather than trusting OCR'd formulas verbatim. This does not block ingestion of the prose content, which is the bulk of the book and OCRs cleanly.
- **Risk**: the quality gate's blind spot to "printable-but-wrong" text (Section 5) means a *future* regression of this same kind (a different broken-CMap PDF) could again pass silently. **Mitigation**: out of scope for task 460, but worth a separate follow-up task if this failure mode recurs — not fabricated here as a workaround.

## Context Extension Recommendations

- **Topic**: Type 3 / no-ToUnicode PDF remediation via OCR.
- **Gap**: `.claude/context/project/literature/` has no documented playbook for "born-digital PDF with broken font encoding -> OCR remediation" as a distinct failure mode from "scanned image PDF needing OCR" or "column-interleaving needing a different converter tier." This task's Section 1 diagnostic method (`pdfinfo` + `pdffonts` to distinguish scan-vs-broken-encoding, then `ocrmypdf --force-ocr` regardless of which) is reusable and not currently written down anywhere in the literature extension's context.
- **Recommendation**: if this pattern recurs (plausible — old `dvips`-era LaTeX PDFs are common in this domain's literature), a short pattern doc under `.claude/context/project/literature/patterns/` capturing the `pdffonts`-based diagnostic and the `--force-ocr` remedy would save re-deriving this from scratch.

## Appendix

- Zotero item key (bibliographic record): `XYYBJH2N`; PDF attachment key: `8YXTY5UA`; file: `/home/benjamin/Documents/Zotero/storage/8YXTY5UA/Gabbay et al. - 2003 - Many-Dimensional Modal Logics Theory and Applications.pdf`.
- Commands run (representative): `pdfinfo`, `pdffonts`, `pdftotext -f 20 -l 25`, `pdftotext` (full document), `ocrmypdf --force-ocr -l eng --output-type pdf`, `pdftotext` on OCR output, `tesseract --list-langs`, `ocrmypdf --version`, `tesseract --version`, one `WebSearch` for bibliographic/availability confirmation.
- Trial artifacts (scratch only, will not persist beyond this session's scratchpad): `trial_sample.pdf`/`trial_sample_ocr.pdf` (pages 20–24), `trial_math.pdf`/`trial_math_ocr.pdf` (pages 150–152).
- Files read (not modified): `.claude/scripts/literature-ingest.sh`, `.claude/scripts/literature-convert.sh` (header/self-test region), `.claude/scripts/literature_quality_gate.py`.

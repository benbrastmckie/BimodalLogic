# Research Report: Task #389

**Task**: 389 - repair_dedekind_literature_corpus
**Started**: 2026-07-25T00:00:00Z
**Completed**: 2026-07-25T15:07:24Z
**Effort**: ~1 session, infrastructure/tooling investigation (no code changes made)
**Dependencies**: None
**Sources/Inputs**:
- `~/Projects/Literature/index.json` (global corpus index)
- `~/Projects/Literature/.literature.db` (SQLite FTS5 index)
- `specs/literature-index.json` (repo-local sub-index)
- `.claude/scripts/literature-convert.sh`, `literature-chunk.sh`, `literature-build-index.sh`, `literature-ingest.sh`, `literature-fidelity-audit.sh`, `literature-pyenv-provision.sh`
- Direct PDF extraction experiments (pdftotext, PyMuPDF/fitz, pymupdf4llm) run against the Rabinovich 2014 PDF
- On-disk PDFs for all Part 2 targets

**Artifacts**:
- This report: `specs/389_repair_dedekind_literature_corpus/reports/01_repair-literature-corpus.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Part 1 fully verified empirically.** Every claim in the task description checks out exactly: 0 occurrences of `≠` (U+2260) vs. 4×`≤`/3×`≥` in the corrupt `.md`; `index.json`'s `rabinovich_2014` entry has `path` pointing at the `.md`, `provenance_fidelity: "verified_conversion"` (false), `token_count: 2721`; 11 chunk rows for `rabinovich_2014` live in `chunks_fts`; the repo-local sub-index already documents the hazard correctly and the two indices do contradict each other.
- **Root cause of the `≠` drop, isolated precisely and reproducibly**: the source PDF encodes "≠" not as the precomposed U+2260 codepoint but as a **decomposed pair** — base `=` glyph plus a **combining U+0338 (COMBINING LONG SOLIDUS OVERLAY)** mark. Raw `PyMuPDF`/`fitz` text extraction (`page.get_text("text")` or `"dict"`) preserves this pair correctly. **`pymupdf4llm.to_markdown()` — the project's PRIMARY conversion engine — silently drops the U+0338 combining mark** during its own internal text-cleanup pipeline, collapsing "k ̸= m" to "k = m". This was verified by running `pymupdf4llm.to_markdown()` directly against the PDF in a freshly-provisioned venv and reproducing the exact corruption at the exact reported lines. `≤`/`≥` survive because they are encoded as ordinary precomposed codepoints in this PDF's font, not via combining overlay — this is a font/CMap-specific defect, not a general Unicode-handling bug.
- **A working alternative conversion path already exists in the repo and was validated**: forcing `LITERATURE_CONVERTER=fallback` (the project's own MANDATORY PyMuPDF column-clustering fallback tier, not an external tool) on the Rabinovich PDF produces output that (a) preserves both instances of the U+0338 combining mark intact, (b) captures the previously-dropped displayed equations (word count 7312 vs. the corrupt primary-tier conversion's much lower yield), and (c) passes the existing quality gate. This is the strongest lead for the repair; it still needs a **post-processing normalization step** (combining-mark composition, e.g. `=`+U+0338 → precomposed `≠`) to satisfy the deliverable's literal "U+2260 count > 0" assertion, since the fallback tier currently emits the *decomposed* form, not the precomposed character.
- **Part 2 fully located and page-mapped.** All five referenced sources have their PDFs on disk with exact paths; precise page ranges were determined for every gap: Gabbay-Hodkinson-Reynolds 1994 Ch.10 §10.3.2 ("Pre-eliminations") spans PDF page indices 11–14 of `Gabbay_Hodkinson_Reynolds_1994_..._ch10.pdf` (confirmed via direct heading search — a genuine conversion gap, not acquisition); Gabbay & Reynolds 2000 Vol.2's rejected conversion is confirmed OCR garbage from a poor scan (Tesseract-driven, e.g. `"UXFORID LOTIC GUIDES"`) — a source-quality problem, not a tooling bug; Reynolds 1992 §9 "Completeness" (real-flow weak completeness, directly on-topic) begins at PDF page index 24 (printed p.189) and is currently un-chunked as its own unit; §5's boundary could not be cleanly isolated from OCR-garbled heading text and needs manual inspection; Hodkinson & Reynolds 2006 Ch.11's "stub" status is an **acquisition gap, not a conversion gap** — the source PDF itself is only 3 pages (TOC + Introduction only; Sections 2-6, pp. 658-712, were simply never acquired) — confirmed by opening the PDF directly.
- **Tooling recommendation**: the pipeline is `literature-ingest.sh` orchestrating `literature-convert.sh` → `literature-chunk.sh` → `literature-build-index.sh --global`. The SQLite index rebuild is a full from-scratch reconstruction (atomic tmp-file + rename) driven entirely by chunk files on disk, so a re-conversion + re-chunk + `--global` rebuild will NOT leave orphaned corrupt chunk rows behind — no manual `DELETE` is needed. `literature-fidelity-audit.sh --write` is the existing, idempotent, backed-up mechanism for stamping `provenance_fidelity`/`word_ratio`, and should be preferred over hand-editing `index.json` for both parts — but its word-ratio heuristic is blind to semantic character-level corruption (word counts don't change when one glyph is dropped), which is *why* it mis-certified Rabinovich as `verified_conversion` in the first place. This is a real system-level gap worth flagging separately.

## Context & Scope

Task 389 has two parts: (1) an emergency repair of a silently-corrupted, falsely-certified literature source (Rabinovich 2014) whose inverted inequality is exactly the material the Dedekind-completeness effort depends on; (2) closing specific, named coverage gaps in the Dedekind-complete-flows literature (Gabbay-Hodkinson-Reynolds 1994 Ch.10 §10.3, Gabbay & Reynolds 2000 Vol.2, Reynolds 1992 §5/§9, Hodkinson & Reynolds 2006 Ch.11, Burgess 1984 §4). This report is infrastructure/tooling research only — it does not attempt the re-conversion, index edits, or re-chunking itself; those are implementation-phase work. All findings below were verified empirically (file greps, byte-level Python inspection, direct PyMuPDF/pymupdf4llm invocation, PDF page-content dumps) rather than inferred from filenames or summaries.

## Findings

### Part 1: Rabinovich 2014 corruption — verification and root cause

**Empirical confirmation of every claim in the task description:**

```
$ grep -c '≠' Rabinovich_2014_Proof_of_Kamps_Theorem.md   → 0
$ grep -c '≤' Rabinovich_2014_Proof_of_Kamps_Theorem.md   → 4
$ grep -c '≥' Rabinovich_2014_Proof_of_Kamps_Theorem.md   → 3
```

Lines 199 and 201 of the current `.md` read exactly as described:
- md:199: `In the first case k = m, i.e., z0 = z1 and in the second k = m.`
- md:201: `If k = m, w.l.o.g. we assume that m < k.`

Both should read `k ≠ m`. This is Section 5, "Proof of Proposition 4.2" of the paper.

**`index.json` entry (`rabinovich_2014`)** — confirmed all three aggravating factors:
```json
{
  "id": "rabinovich_2014",
  "path": "sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md",
  "token_count": 2721,
  "provenance_fidelity": "verified_conversion",
  "word_ratio": 0.7949,
  "page_range": "1-16"
}
```
`path` points at the corrupt `.md` (not the PDF); `provenance_fidelity` is `"verified_conversion"` (false); `token_count` 2721 for a 16-page paper is low, consistent with the equation-dropping issue (see below).

**`.literature.db` chunk rows**: `SELECT count(*) FROM chunks_fts WHERE chunks_fts MATCH 'rabinovich'` → **11**. Every `--lit` briefing that touches this document serves the corrupted text.

**Repo-local sub-index** (`specs/literature-index.json`) already carries a detailed, accurate hazard block for `rabinovich_2014`, including the exact `k != m → k = m` inversion at md:199, a note that a *prior* hand-written paraphrase (preserved as `*.md.bak-20260709T235817Z`) was replaced on 2026-07-09T23:58:17Z by the current PDF-text-extract (which is where this corruption was introduced), and a list of 89 dangling `md:NN` citations in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`. The sub-index and the global index do genuinely contradict each other (global says verified/trustworthy path=`.md`; sub-index says both historical `.md` variants are unsafe and mandates PDF-page-only citation). **This confirms the task's framing precisely: the global index "wins" for `--lit` retrieval since `literature-briefing.sh` and `literature-search.sh` read `provenance_fidelity` from the global index, not the sub-index's free-text `hazard` field.**

**Root cause, isolated and reproduced:**

1. `pdftotext` (both plain and `-layout`) on the actual PDF page renders the symbol as literal `6=` (a poppler-specific rendering quirk for this glyph): `We consider two cases. In the first case k = m, i.e., z0 = z1 and in the second k 6= m.` — this is on PDF page 7 (1-indexed via `pdftotext -f/-l`).
2. Raw `PyMuPDF`/`fitz` `page.get_text("text")` on the same page (`doc[6]`, 0-indexed — **printed page 7**, not page 6; see numbering note below) renders it correctly with the true Unicode content: `k ̸= m`. Character-level inspection shows this is **not** the precomposed U+2260 but a **two-codepoint sequence**: U+0338 (COMBINING LONG SOLIDUS OVERLAY) immediately followed by `=` (U+003D). Two occurrences on this page, matching exactly the two corrupted lines (md:199, md:201).
3. `≤`/`≥` in the same document are ordinary precomposed codepoints (U+2264/U+2265), which is why they survived while `≠` did not — this is specific to how this PDF's embedded font encodes the negation slash for `=`, not a general Unicode-stripping bug.
4. **Direct reproduction of the bug**: with a freshly-provisioned `pymupdf4llm==1.28.0` venv (see Tooling section), calling `pymupdf4llm.to_markdown(pdf_path, page_chunks=False)` directly and grepping the output for the same sentence reproduces the corruption byte-for-byte: `'...in the second k = m. If k = m...'`, with `md.count("≠") == 0` and `md.count(chr(0x338)) == 0` over the **entire 16-page document**. `pymupdf4llm`'s own internal markdown-generation pipeline is where the combining mark is silently dropped — not `literature-convert.sh`'s own normalization code (its `normalize_unit`/`normalize_document` functions do ligature-folding, dehyphenation, and whitespace collapse only; no NFC/NFKC and no combining-mark handling, confirmed by reading the script).
5. **The project's own MANDATORY FALLBACK tier does not have this bug.** Forcing `LITERATURE_CONVERTER=fallback bash .claude/scripts/literature-convert.sh <pdf> <scratch-dir>` (the zero-dependency PyMuPDF column-clustering fallback, always available, no `pymupdf4llm` needed) produced a converted `.md` where both combining-mark occurrences survive intact (`chr(0x338)` count = 2, verified with the exact `k ̸= m` context around both). The fallback conversion also captured substantially more content overall (7312 words vs. the primary tier's much smaller 2721-token output) and passed `literature-convert.sh`'s own quality gate (`[convert] Quality gate: PASSED`, engine=`pymupdf-fallback-toc`, headings=11).

**Important correction to the task description's page reference**: "PDF p.6" should be **printed page 7** (PyMuPDF 0-indexed `doc[6]`; `pdftotext -f 7 -l 7`). Printed page 6 (`doc[5]`) is the page immediately before Section 5 begins and does not contain the case-split text. This numbering ambiguity (0-indexed vs. 1-indexed vs. printed-page-number, all of which differ here by exactly one from each other in a way that's easy to conflate) should be resolved explicitly in the implementation plan to avoid a spot-check against the wrong page.

**What remains for a full fix (not attempted here, flagged for planning)**: the fallback tier preserves the *decomposed* combining-mark form (`=` + U+0338), not the precomposed U+2260 character the deliverable's verification criterion asks for ("assert the U+2260 count is greater than zero"). A small, targeted post-processing normalization step is needed — e.g., a regex substitution recognizing `<base-char><U+0338>` pairs and mapping known cases to their precomposed negated-operator codepoints (at minimum `=` + U+0338 → `≠`; the same combining-overlay technique is used by TeX/LaTeX-descended PDFs for other negated relations like `∉`, `≁`, `≮`, so a general mapping table is safer than a single hard-coded substitution if other documents in the corpus share this PDF-generation toolchain). This belongs in `literature-convert.sh`'s `normalize_unit()`/`normalize_document()` functions (which already run post-extraction, for both tiers) or as a corpus-specific override to avoid touching the shared quality gate. Two engineering choices for the plan to weigh: (a) special-case Rabinovich to always use `LITERATURE_CONVERTER=fallback` plus the new normalization step, or (b) add the same combining-mark composition step upstream of the existing `normalize_document()` shared by both engine tiers, which would also protect any other PDF in the corpus using the same negation-slash-via-combining-mark convention (not otherwise audited in this report — out of scope, flagged as a corpus-wide risk).

### Tooling Inventory

- **Engine tiers** (from `literature-convert.sh` header comments and code, confirmed against actual execution):
  1. **PRIMARY**: `pymupdf4llm.to_markdown()` via a pinned (`1.28.0`), auto-provisioned `uv` venv (`literature-pyenv-provision.sh`). Correct multi-column reading order and markdown structure; **this is where the `≠` bug lives**.
  2. **MANDATORY FALLBACK**: zero-dependency raw `PyMuPDF` `page.get_text("blocks")`/`"dict"` + custom column-clustering reading-order reconstruction (implemented directly in `literature-convert.sh`, ~400 lines, uses an x-axis occupancy histogram to detect column bands and never does a whole-page row-major sort). Always available (system `fitz` is a hard prerequisite of the whole pipeline). **Does not exhibit the `≠` bug** (verified above).
  3. **Explicit escape hatch**: `LITERATURE_CONVERTER=pdftotext` — plain `pdftotext`, no layout flag, no heading detection; manual-only, never used by `auto`.
  - `pdftotext -layout`, PyMuPDF row-major whole-page sort, `marker`/`marker_single`/`docling`/`nougat` are all explicitly rejected/never used (documented in the script's own header comments as prior research findings — heavy deps, OpenRAIL license, GPU-oriented, column-gluing bugs).
- **Environment control**: `LITERATURE_CONVERTER` env var selects `auto` (default; primary with automatic fallback), `pymupdf4llm` (primary-only, fails loud if unavailable), `pymupdf`/`fallback` (force fallback tier — used in this report's experiment), `pdftotext` (explicit escape hatch).
- **Quality gate**: `literature-convert.sh` exit code 3 means the engine ran but failed a correctness gate (column-interleaving, page-coverage shortfall, unresolved ligatures/hyphens); output goes to `<name>.md.rejected`, never to the final `.md`. This is exactly what happened for `gabbay_2000` (see Part 2 below) — confirmed by inspecting the `.md.rejected` file, which is genuine Tesseract OCR garbage (`"UXFORID LOTIC GUIDES"`, `"NCJ('II"U]JBI[J&CA'R [CINS"`), not a tooling misconfiguration — the source scan quality itself is the blocker.
- **Venv provisioning**: `literature-pyenv-provision.sh` is idempotent and was successfully re-run during this research session (`uv` + `nix-build` were both available in this environment) to provision a working `pymupdf4llm` venv at `.claude/scripts/literature-pyenv/venv/` for direct experimentation. This venv is gitignored/ephemeral by design.
- **Orchestration**: `literature-ingest.sh <path>` chains `literature-convert.sh` → `literature-chunk.sh` → global `index.json` update → `literature-build-index.sh --global` → optional local copy/reindex. This is the correct top-level entry point for re-ingesting a corrected Rabinovich `.md` or a newly-converted §10.3.2/§9 chunk, rather than invoking the sub-scripts by hand.
- **Index rebuild semantics** (`literature-build-index.sh`): the SQLite `.literature.db` is explicitly documented as "ephemeral — rebuilt from chunk files on disk" using an atomic tmp-file + rename. This means a full `--global` rebuild after re-conversion will **not** leave the 11 old corrupt `rabinovich_2014` chunk rows behind as orphans (the whole DB is reconstructed fresh from whatever `chunk_*.md`/`chunks.json` files currently exist on disk) — no manual `DELETE FROM chunks_data` step is needed, contrary to what the `chunk_id` = `sha256(doc_id+section_path+content_hash)` scheme might otherwise suggest (that scheme matters for `INSERT OR REPLACE` semantics within a single incremental build, not for the `--global` full-rebuild path).
- **Fidelity/provenance tooling**: `literature-fidelity-audit.sh` is a pre-existing, re-runnable, idempotent tool (task history embedded in its own header comments references a six-value `provenance_fidelity` enum: `verified_conversion`, `unverified_summary`, `no_source_pdf`, `not_yet_converted`, `unverified_no_baseline`, `unadjudicated`) that computes a whole-document word-ratio (converted words / PDF words via `pdftotext -layout`) plus a disclosure check and a proof/body-completeness check, then optionally stamps `provenance_fidelity`/`word_ratio` onto `index.json` (`--write`, with automatic timestamped backup and atomic write). **This is almost certainly the tool that originally produced Rabinovich's `word_ratio: 0.7949` and `provenance_fidelity: "verified_conversion"`** — and its failure to catch the corruption is instructive: a single-character semantic inversion (`≠`→`=`) does not move the word-ratio at all, so this heuristic is structurally blind to exactly this failure mode. This is worth surfacing as a Context Extension Recommendation (below) rather than treating Rabinovich as a one-off data-entry error.
- **Search-time behavior**: `literature-search.sh` and `literature-briefing.sh` both look up `provenance_fidelity` per `doc_id` from the global `index.json` (confirmed via `grep -n "provenance_fidelity"` across both scripts) and surface an `[UNVERIFIED - provenance_fidelity: ...]` banner for anything not `verified_conversion` — which is exactly why the false `"verified_conversion"` stamp is dangerous: it suppresses the one safety banner that would otherwise have warned every `--lit` consumer.

### Part 2: Coverage-gap sources — locations, page ranges, and priority signal

**Gabbay-Hodkinson-Reynolds 1994, Vol.1, Ch.10 "Since and Until"**
- PDF on disk: `~/Projects/Literature/sources/gabbay_1994/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.pdf` (25 pages, no embedded TOC).
- Existing converted chunks (`index.json` entries, all with `provenance_fidelity` **absent/null**, confirming the task's "unadjudicated" claim for 10.3.1/10.3.3/10.3.4):
  - `gabbay_1994_ch10_sec01` — §10.1-10.2 Introduction (`ch1001_...`)
  - `gabbay_1994_ch10_sec02` — **§10.3.1** Introduction to Separation over Dedekind Complete Flows (`ch1002_1031-introduction.md`)
  - `gabbay_1994_ch10_sec03` — **§10.3.3** Eliminations (`ch1003_1033-eliminations.md`)
  - `gabbay_1994_ch10_sec04` — **§10.3.4** Induction (`ch1004_1034-induction.md`)
- **§10.3.2 confirmed absent** and located precisely: direct heading search (`re.match(r'^10\.3\.\d', line)` over every page's extracted text) finds `10.3.1` at PDF page index 8, `10.3.2` at index 11, `10.3.3` at index 15, `10.3.4` at index 19 — i.e. **§10.3.2 "Pre-eliminations" spans PDF page indices 11–14 (4 pages)** of `Gabbay_Hodkinson_Reynolds_1994_..._ch10.pdf`. Its opening content (`Lemma 10.3.5`, negation-lemma identities for `~U(A,B)` and `~S(A,B)` over Dedekind complete flows) is exactly the load-bearing separation machinery the task is targeting. This is a genuine **conversion gap** — the source PDF has the content; it was simply never chunked into `index.json`.
- A `.bak-20260710T000400Z` sibling exists for the ch10/ch9/ch12/Vol1 PDFs, consistent with a prior re-conversion pass on 2026-07-09/10 (same timeframe as the Rabinovich `.bak`) — not further investigated, flagged only as background context that this corpus underwent a bulk re-conversion recently.

**Gabbay & Reynolds 2000, Vol.2**
- PDF on disk: `~/Projects/Literature/sources/gabbay_2000/Gabbay_Reynolds_2000_Temporal_Logic_Foundations_Vol2.pdf` (59MB).
- `index.json` entry: `token_count: 0`, `provenance_fidelity: "not_yet_converted"` (not literally "rejected" as the task description phrased it, but functionally equivalent — no usable markdown exists).
- A `.md.rejected` sibling (`gabbay_reynolds_2000_temporal_logic_foundations_vol2.md.rejected`, 252,819 words) confirms a conversion attempt WAS made and DID fail the quality gate — inspected directly: the content is genuine OCR garbage (Tesseract-driven; e.g. `"UXFORID LOTIC GUIDES » 40"`, `"IMIAIRIC A, IREEYNOILIDS"`, `"NCJ('II"U]JBI[J&CA'R [CINS"`) rather than any tooling misconfiguration. **This is a source-scan-quality problem** — the PDF is apparently a low-quality scan requiring OCR (no clean embedded text layer), and Tesseract's output on it is unusable. Re-running the same pipeline is unlikely to help; the plan should consider sourcing a better-quality scan (e.g. via Zotero/online discovery per the `--lit` literature-discover.sh path) before re-attempting conversion, or accept a manual/partial extraction of just the axiomatization-relevant chapters.

**Reynolds 1992 "An Axiomatization for Until and Since over the Reals without the IRR Rule"**
- PDF on disk: `~/Projects/Literature/sources/reynolds_1992/Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf` (29 pages, printed pagination 165-193, no embedded TOC).
- Converted sections present: `sec01` (§1-2, pp.165-172), `sec02` (§3-4, pp.173-179), `sec03` (§6, pp.180-183), `sec04` (§7-8, pp.184-188), `sec05` (§10, pp.189-193). **§5 and §9 are confirmed absent as their own chunks**, consistent with the task description.
- **§9 "Completeness" located precisely**: direct page-content inspection confirms an explicit `"9 Completeness"` heading begins on PDF page index 24 (**printed page 189**) — content: `THEOREM 7. The system US/R is sound and weakly complete for the semantics over structures with real flow`, `Soundness has been proven in lemma 1. To show weak completeness...`, invoking `Burgess-Xu Corollary 1`. **This is directly on-topic for "axiomatization-over-real-flows material"** and appears to be currently un-separated from the adjacent `sec05` chunk (which is labeled only "§10" but whose page range, 189-193, starts on the exact same page §9 begins on) — the existing chunk boundary likely straddles §9/§10 without a clean split; a re-chunk with an explicit `10.3.2`-style heading search (as used successfully above for Gabbay Ch.10) would resolve this.
- **§5's boundary could not be cleanly isolated**: this PDF's extracted text is visibly poor-quality OCR (e.g. `"K-(-,R)"` for `¬(¬R)`, `"9"` used as a bullet-point glyph, `"~-~M"` garbling, `"vy"` for `∀y`) — worse quality than the Rabinovich or Gabbay 1994 PDFs, which extract cleanly. A search for a `"5 <Title>"`-style heading across PDF page indices 12-15 (printed pp.177-180, the region bracketed by the end of §4 and the start of §6) found no clean match; the surrounding lemma-numbered content (Lemmas 2-6) appears continuous across that boundary without an obvious section break in the extracted text. **Recommend a manual/visual PDF inspection of pp.177-180** (rather than further automated heading search) to locate §5's actual boundary, given the OCR quality — automated search is unreliable here in a way it was not for the other three gap-closure targets in this report.
- **Priority signal for the plan**: §9 (real-flow completeness) is unambiguously on-topic and precisely located — high-confidence, ready to convert. §5's relevance to "the countable-carrier obstruction" could not be determined from page-boundary/heading evidence alone within this report's scope; its content (based on the surrounding Lemma 2-6 material about contemporaneous-equivalence classes, gaps, and R/L relations) appears to be more about the *general* gap-handling machinery than specifically about countable carriers, but this is a weak inference from adjacent context, not a direct read of §5 itself, and should be treated as provisional.

**Hodkinson & Reynolds 2006, Handbook of Modal Logic Ch.11 "Temporal Logic"**
- PDF on disk: `~/Projects/Literature/sources/hodkinson_2006/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.pdf`.
- **Confirmed: the PDF itself is only 3 pages** (opened directly with PyMuPDF: `len(doc) == 3`). The converted `.md` (1611 words, matching `index.json`'s `token_count: 2094`) ends with an explicit, already-present disclosure note: `"Note: This PDF contains only the table of contents and the Introduction (Section 1) of Chapter 11. Sections 2--6 (pages 658--712) are not included in the source PDF."` **This is an acquisition gap, not a conversion gap** — no amount of re-running the conversion pipeline will recover Sections 2-6; a complete 65-page PDF needs to be sourced (e.g. via the `/literature --search`/`literature-discover.sh` online-discovery path) before any re-conversion is worthwhile. `provenance_fidelity: "verified_conversion"` is arguably *correct* here in the narrow sense that the conversion faithfully represents everything the (incomplete) source PDF contains, and the summary/tail-note already discloses the gap — this is a materially different situation from Rabinovich's silent corruption and should not be remediated the same way.

**Burgess 1984, "Basic Tense Logic" §4 "Expressive Completeness and Kamp's Theorem"**
- PDF on disk: `~/Projects/Literature/sources/burgess_1984/Burgess_1984_Basic_Tense_Logic.pdf`.
- Existing chunk: `burgess_1984_sec07` (`sec07_basic-tense-logic-time-periods.md`), `page_range: "122-133"` (11 pages), `token_count: 982`, matching the task's "982 tokens for 11 pages (stub)" description exactly. `provenance_fidelity: "verified_conversion"` is already stamped (this one is not flagged as a fidelity problem by the task — only as thin/stub coverage warranting expansion). Already registered in the sub-index (`burgess_1984_sec04` entry, described as "Chronicles and Killing Lemma... single-witness in structure" — note this sub-index entry's `doc_id` maps to a *different* section than `burgess_1984_sec07`; the sub-index's own reference appears to point at the completeness/chronicles section rather than the §4 expressive-completeness section named in the task, worth double-checking cross-references during planning).

### index.json / literature-index.json Schema (for precise field-edit planning)

**Global `~/Projects/Literature/index.json`** — top-level: `{description, entries[], max_chunks, token_budget, version}`. Each entry (fields observed across samples; not all fields present on every entry — e.g. `provenance_fidelity`/`word_ratio` are absent, not null, on unaudited entries):
```
id, bib_key, title, authors[], year, section, path, page_range,
token_count, keywords[], summary, doc_type, source_format,
zotero_key, zotero_path, project_tags[], parent_doc,
provenance_fidelity (six-value enum, may be absent), word_ratio (may be absent/null)
```
`path` is relative to `$LITERATURE_DIR` (e.g. `sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`) — for the Part 1 fallback fix ("repoint path at the PDF"), the corresponding PDF path would be `sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.

**Repo-local `specs/literature-index.json`** — top-level: `{version, updated, entries[]}`. Each entry: `{doc_id, reason, hazard? (free text), known_corrections?[] (free text array), citation_rule? (free text), audits?[] (paths to audit reports)}`. This is a reference-only pointer index (no cached metadata) — `doc_id` values must match global `index.json` `id` values for `literature-briefing.sh` to resolve them. The existing `rabinovich_2014` entry's `hazard`/`known_corrections` fields are already comprehensive and internally correct; the task's "confirm the sub-index hazard block matches reality afterward" deliverable is about verifying (not necessarily rewriting) this block once the global-index fix lands, since the sub-index already anticipated exactly this failure mode.

## Decisions

- No files were modified during this research session; the `literature-pyenv` venv was provisioned as an ephemeral, gitignored side effect of testing (consistent with its documented design) and is not a deliverable.
- The scratch re-conversion test (`LITERATURE_CONVERTER=fallback`) was written only to `/tmp/.../scratchpad/rabinovich-test/` (outside the repo and outside `~/Projects/Literature`), not to the actual corpus — the real fix still needs to be applied by the implementation phase, including the combining-mark-composition normalization step this report identified as still missing.
- Treated "PDF p.6" in the task description as a minor numbering imprecision (confirmed the actual location is printed page 7 / PyMuPDF index 6) rather than a discrepancy requiring escalation — noted explicitly above so the implementation phase doesn't spot-check the wrong page.

## Risks & Mitigations

- **Risk**: fixing only Rabinovich's `≠` glyph without addressing the separately-reported "displayed equations dropped" issue (token_count 2721 for 16 pages) would leave a partially-repaired document that still under-represents the source. **Mitigation**: the validated fallback-tier conversion happens to address both problems simultaneously (it preserves combining marks AND captures substantially more content, 7312 vs. ~2721-token-equivalent words) — the plan should verify displayed-equation coverage (e.g. Definition 3.1, Lemma 5.1's full displayed formula) in the fallback-tier output as part of its own acceptance check, not just the `≠` count.
- **Risk**: the combining-mark-drop bug in `pymupdf4llm` is not necessarily unique to Rabinovich — any other document in the ~280-entry corpus converted via the primary tier and containing PDF fonts that encode negated relations (`≠`, `∉`, `≁`, `≮`, etc.) via combining overlay rather than precomposed codepoints could have the same silent corruption, undetected by `literature-fidelity-audit.sh`'s word-ratio heuristic. **Mitigation**: this report does not attempt a corpus-wide audit (out of scope), but flags it as a high-value Context Extension Recommendation below; a cheap grep-based sweep (search all `verified_conversion`-stamped `.md` files for `=` immediately preceded by common negation contexts, or simply grep for any leftover bare U+0338 in case some documents partially survive) would be a good first step for whoever picks this up.
- **Risk**: re-stamping `provenance_fidelity` for the Gabbay 1994 §10.3.1/10.3.3/10.3.4 entries and the newly-converted §10.3.2 via `literature-fidelity-audit.sh --write` alone would not constitute the "actual spot-check against the source PDF" the task explicitly requires ("Do NOT mark anything verified_conversion without an actual spot-check"). **Mitigation**: the automated audit's word-ratio/disclosure/proof-completeness heuristic is a useful pre-filter but should be treated as necessary-not-sufficient; the implementation phase should pair it with the same kind of direct heading/content dump against the PDF this report used for §10.3.2 and §9 before flipping any entry to `verified_conversion`.

## Context Extension Recommendations

- **Topic**: PDF combining-mark (U+0300–U+036F range) handling in the conversion pipeline.
- **Gap**: neither `literature-convert.sh`'s `normalize_unit()`/`normalize_document()` nor `pymupdf4llm`'s internal cleanup has any documented handling for combining diacritical marks used as negation-slash overlays (a fairly common PDF-generation convention for `\not=`-style LaTeX macros). `literature-fidelity-audit.sh`'s word-ratio-based fidelity heuristic is structurally blind to this exact failure mode (a single dropped combining character changes zero words).
- **Recommendation**: after the Rabinovich-specific fix lands, consider a small addition to `literature-convert.sh`'s shared `normalize_unit()` (used by both engine tiers) that composes known `<base><U+0338>` sequences into their precomposed negated-operator codepoints, and a follow-up note in `literature-fidelity-audit.sh`'s header comments (or a new lightweight signal) documenting that character-level semantic inversions are a known blind spot of the current three-signal detector. This is a candidate for a small dedicated follow-up task rather than folding into task 389's implementation phase, since it is corpus-wide in scope rather than specific to the Dedekind-completeness effort.

## Appendix

**Key commands/queries used** (for the implementation phase to reuse verbatim):
```bash
# Part 1 verification
grep -c '≠' ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md
sqlite3 ~/Projects/Literature/.literature.db \
  "SELECT count(*) FROM chunks_fts WHERE chunks_fts MATCH 'rabinovich'"
jq -c '.entries[] | select(type=="object") | select(.id=="rabinovich_2014")' \
  ~/Projects/Literature/index.json

# Reproduce the pymupdf4llm bug (after `source .claude/scripts/literature-pyenv-provision.sh; literature_pyenv_ensure`)
LD_LIBRARY_PATH="$(literature_pyenv_shim_prefix)" "$(literature_pyenv_python)" -c "
import pymupdf4llm
md = pymupdf4llm.to_markdown('<pdf>', page_chunks=False)
print(md.count('≠'), md.count(chr(0x338)))"

# Validate the fallback-tier fix
LITERATURE_CONVERTER=fallback bash .claude/scripts/literature-convert.sh <pdf> <scratch-dir>

# Locate a numbered sub-heading precisely (reused for Gabbay 10.3.2 and Reynolds §9)
python3 -c "
import fitz, re
doc = fitz.open('<pdf>')
for i in range(len(doc)):
    for line in doc[i].get_text('text').split(chr(10)):
        if re.match(r'^<pattern>', line.strip()): print(i, line.strip())"
```

**Important caveat about `jq` on this `index.json`**: the file contains at least one entry with a non-string field that breaks naive `jq '.entries[] | select(.id == "...")'` queries (`jq: error ... null (null) cannot be matched, as it is not a string`) partway through the file. Use `select(type=="object")` guards or `grep -n` on the raw file first to locate line numbers, as this report did, rather than assuming a clean `jq` query will complete without a guard.

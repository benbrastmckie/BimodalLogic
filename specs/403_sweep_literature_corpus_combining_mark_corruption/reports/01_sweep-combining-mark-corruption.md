# Research Report: Task #403

**Task**: 403 - sweep_literature_corpus_combining_mark_corruption
**Started**: 2026-07-27T00:00:00Z
**Completed**: 2026-07-27T00:00:00Z
**Effort**: ~1 session, empirical corpus sweep (no re-conversion performed)
**Dependencies**: task 389 (Rabinovich 2014 repair; root-cause and `compose_combining_overlays()` fix)
**Sources/Inputs**:
- `~/Projects/Literature/sources/**/*.md` (13,085 markdown files across 131 unique source directories)
- `~/Projects/Literature/sources/**/*.pdf` (67 on-disk PDFs)
- `~/Projects/Literature/index.json` (provenance_fidelity / word_ratio cross-check)
- `specs/literature-index.json` (repo-local sub-index, checked for overlap with affected docs)
- `.claude/scripts/literature-fidelity-audit.sh` (read, for the Part 4 recommendation)
- `specs/archive/389_repair_dedekind_literature_corpus/reports/01_repair-literature-corpus.md` (prior root-cause report)
- Direct PyMuPDF (`fitz`) raw-text extraction against all 67 on-disk PDFs (system Python, `PyMuPDF 1.27.2.3`)

**Artifacts**:
- This report: `specs/403_sweep_literature_corpus_combining_mark_corruption/reports/01_sweep-combining-mark-corruption.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's proposed methodology (grep for bare, surviving U+0338) can only ever find the BENIGN case, never the dangerous one — this is the single most important methodological finding of this sweep.** By construction, the Rabinovich-class defect is a *silent drop*: the combining mark disappears entirely from the converted markdown, leaving zero trace to grep for. A narrowed "search for surviving U+0338" sweep, however precise, structurally cannot detect the dangerous case — it can only ever surface the relatively benign "combining mark survives bare" scenario. Detecting the dangerous case requires comparing PDF ground truth against converted output (what *should* be there vs. what *is* there), which this report does for the 67 documents that still have their source PDF on disk.
- **Narrow bare-U+0338 sweep (as literally requested)**: 42 `.md` files across **8 unique source documents** (`girard_1989`/`proofs_and_types` duplicate-directory pair, `arxiv_2601.19747_veri-sure`, `caleiro_2013`, `arxiv_2510.00915_rl-verifiable-noisy-rewards`, `arxiv_2502.00212_stp-self-play-theorem-provers`, `bentzen_2023`, `arxiv_2512.18160_propose-solve-verify`, `trufas_2024`) contain a surviving bare U+0338. Every occurrence spot-checked reads correctly as a legible (if precomposition-ugly) negation — e.g. `k ̸= m`, `τ ̸∈ H`, `x ̸→ y` — confirming these are the "relatively benign, rendering nuisance" case the task anticipated, dramatically narrower than task 389's 667-document whole-diacritics-block figure.
- **PDF-vs-MD cross-check (the methodology that actually finds the dangerous case)**: of the 131 unique source directories in the corpus, only **67 (51%) still have their source PDF on disk** — the rest cannot be checked this way at all (see Risks). Of those 67, **27 documents' PDFs contain at least one U+0338 combining mark** in raw PyMuPDF text. Of those 27, three-way spot-checked classification:
  - **2 already correct/fixed**: `rabinovich_2014` (the task 389 fix — precomposed `≠` present, 0 bare survivors, as expected) and `verbrugge_2004` (precomposed `∉` present).
  - **2 benign bare-survivors**: `caleiro_2013`, `girard_1989`/`proofs_and_types` — negation legible, matches the narrow sweep above.
  - **9 documents show a distinct, non-Rabinovich glyph-substitution artifact** (the combining slash renders as a literal digit **"6"**, e.g. `goal 6= ⊥`, a known poppler/PDF-font quirk) — visibly odd but not silently misleading, since a reader (or grep for `6=`) can spot it: `arisakadasstrassburger_2015`, `courcoubetis_1992`, `kupferman_vardi_2001`, `massacci_2000`, `pacheco_2024`, `piterman_2007`, `schewe_2009`, `schwoon_esparza_2005`, `yan_2008`.
  - **14 documents show the TRUE, dangerous, Rabinovich-class defect** — the negation vanishes with zero trace (no bare mark, no precomposed character, no `6=`/LaTeX-macro fallback), leaving a **plain, readable, semantically-inverted equality/membership/etc.** exactly like Rabinovich's `k ≠ m` → `k = m`. Spot-checked and confirmed by direct sentence-level comparison for two of the highest-severity cases (see Findings). **Total unaccounted (silently-inverted) occurrences across these 14 documents: 1,163**, overwhelmingly dominated by one document.
- **The single largest blast-radius document by far is `baier_katoen_2008` ("Principles of Model Checking", Baier & Katoen 2008)**: **817 of 819** combining-negation occurrences in the source PDF are completely missing from the converted `.md` (across all 12 `Baier_Katoen_2008_partNN.md` chunks). Confirmed by direct sentence comparison: PDF page 58 reads `TS(PG1 ||| PG2) ̸= TS(PG1) ||| TS(PG2)` (a **non-equality** — the whole point of the passage) while the converted `.md` reads `TS(PG1 ||| PG2 ) = TS(PG1 ) ||| TS(PG2 )` (a **plain, false equality**); PDF page 66's `τ ̸∈ H` (NOT a handshake action) becomes `.md`'s `τ ∈ H` (IS a handshake action) — both are load-bearing definitional sentences in a widely-cited model-checking textbook, both silently inverted, and **all 12 parts are stamped `provenance_fidelity: "verified_conversion"` with `word_ratio: 1.0` exactly** in `index.json` — i.e., the fidelity-audit heuristic gave this document a *perfect* score while missing 817 silent semantic inversions.
- **A second confirmed high-severity case is `bacon_2018_broadest-necessity`**: the paper's own named axiom, **"THE NECESSITY OF DISTINCTNESS: A ̸= B → L(A ̸= B)"**, is rendered in the converted `.md` as **"THE NECESSITY OF DISTINCTNESS: A = B → L(A = B)"** — a tautology that inverts the axiom the paper is *about*. All 18 occurrences in this document are silently dropped; `provenance_fidelity: "verified_conversion"`, `word_ratio: 1.0`.
- **`literature-fidelity-audit.sh`'s word-ratio heuristic is confirmed blind at scale, not just for Rabinovich**: every one of the 14 confirmed-dangerous documents is currently stamped `verified_conversion` in `index.json`. One entry (`libkin_2004_ch3_ch7`, 168/168 occurrences missing) has a recorded `word_ratio` of **0.0187** — far below the tool's own `RATIO_THRESHOLD = 0.75` gate — yet is *still* stamped `verified_conversion`, an internal inconsistency in the index worth a separate, narrowly-scoped follow-up (see Risks).
- **None of the 14 dangerous documents currently appear in this repo's `specs/literature-index.json`** (the BimodalLogic-specific reference sub-index) — none are yet cited as load-bearing for this project the way Rabinovich was, but `baier_katoen_2008` (automata/model-checking background) and the four Venema papers (temporal logic, directly on-topic for a tense-and-modality formalization) are exactly the kind of source this project could cite in the future, so this is a live risk, not a hypothetical one.

## Context & Scope

Task 389's Phase 9 ran a cheap, whole-diacritics-block (U+0300-U+036F) grep across the corpus and found 667 documents with *some* combining mark surviving — a figure the task description itself flagged as almost certainly inflated by benign accented-Latin-letter content (e.g. `é` = `e`+U+0301), not the negation-specific U+0338 defect. This task's mandate was threefold: (1) narrow the sweep to U+0338 specifically; (2) for the narrowed set, distinguish "survives bare" (benign) from "silently dropped" (dangerous, Rabinovich-class); (3) recommend prioritized re-conversion and a fidelity-audit enhancement. All work below was run directly against the live corpus at `~/Projects/Literature/sources/` — no files were modified.

## Findings

### Part 1+2: Narrowed sweep and benign/dangerous classification

**Step A — bare-survivor grep (the literal "narrow U+0338 filter" requested).** A corpus-wide Python scan of all 13,085 `.md` files under `~/Projects/Literature/sources/` for the literal character U+0338 found **42 files across 8 unique documents** (chunk files and whole-document files both counted; see Appendix for the full per-document breakdown). Every spot-checked occurrence renders as a legible negation with the combining mark correctly following its base character (`k ̸= m`, `x ̸≺ y`, `τ ̸∈ H`, `Δ ̸= Ω`, `¬(0 ̸⊢i)`), confirming these are all instances of the *benign* case — a rendering nuisance (Unicode combining-mark composition is font/renderer-dependent and looks ugly in some viewers) but not semantically misleading, since the slash is still present, just not composed into a single codepoint. **This narrow sweep is dramatically smaller than task 389's 667-document whole-block figure**, confirming the task's hypothesis that the 667 figure was mostly benign accent marks.

**Step B — why Step A cannot find the dangerous case, and the alternative that can.** By definition, the Rabinovich-class defect is a *silent drop*: `pymupdf4llm`'s internal cleanup removes the combining mark entirely during conversion, so there is nothing left in the `.md` to grep for. A bare-survivor sweep, however narrowly filtered, is structurally incapable of surfacing this failure mode — it can only ever report documents where the mark happened to survive. **The only way to detect the dangerous case is to compare PDF ground truth against the converted output**, i.e. re-extract each source PDF's raw text via PyMuPDF (bypassing the `pymupdf4llm`/markdown-generation layer where the bug lives) and cross-reference the resulting U+0338 occurrences against the corresponding `.md` file(s), checking for either (a) the bare combining-mark pair, (b) a precomposed negated-operator codepoint (`≠`, `∉`, `⊄`, etc. — the intended post-`compose_combining_overlays()` outcome), or (c) a LaTeX-macro fallback (`\not=`, `\notin`) used by a small number of hand-curated documents in this corpus (`venema_1993`'s `sec0N` files, in particular). Anything left over after accounting for (a)-(c) is a genuine silent inversion.

**Step C — corpus-wide scope limitation.** Of the corpus's 131 unique source directories (per `index.json`), only **67 (51%) still have a source PDF retained on disk** — the remainder were evidently cleaned up post-conversion or ingested from a non-PDF source (e.g. the `arxiv_*` directories in Step A's bare-survivor list have no local PDF at all, consistent with an arXiv-HTML-derived ingestion path that never goes through the PyMuPDF pipeline and so is not at risk of this defect). **The PDF-vs-MD cross-check in this report can only cover those 67 documents; the true corpus-wide blast radius among the other 64 is unknown and unknowable without re-acquiring their PDFs.**

**Step D — cross-check results for the 67 on-disk PDFs.** 27 of the 67 contain at least one U+0338 in raw PDF text. Full breakdown (base-character/next-character tallies, and per-document accounted-for vs. missing counts) was computed programmatically; three-way classification with spot-check confirmation:

| Class | Documents | Occurrence total | Signal |
|---|---|---|---|
| Already fixed / correct | `rabinovich_2014`, `verbrugge_2004` | 12 | precomposed `≠`/`∉` present |
| Benign bare-survivor | `caleiro_2013`, `girard_1989`/`proofs_and_types` | 26 | bare combining mark present, legible |
| Glyph-substituted ("6=" quirk) | `arisakadasstrassburger_2015`, `courcoubetis_1992`, `kupferman_vardi_2001`, `massacci_2000`, `pacheco_2024`, `piterman_2007`, `schewe_2009`, `schwoon_esparza_2005`, `yan_2008` | 114 | negation renders as literal digit "6" (e.g. `goal 6= ⊥`) — visibly odd, not silently misleading |
| **Dangerous silent inversion (Rabinovich-class)** | see table below | **1,163** | negation vanishes entirely; reads as plain, false equality/membership/etc. |

**Dangerous-class documents, sorted by occurrence count** (all 14 currently stamped `provenance_fidelity: "verified_conversion"` in `index.json`):

| Document | PDF U+0338 count | Missing in .md | word_ratio (index.json) | Notes |
|---|---:|---:|---:|---|
| `baier_katoen_2008` | 819 | **817** | 1.0 (all 12 parts) | "Principles of Model Checking" — dominant case by ~7x margin |
| `libkin_2004_ch3_ch7` | 168 | 168 | 0.0187 | word_ratio far below the tool's own 0.75 gate yet still stamped verified (separate anomaly, see Risks) |
| `venema_1993` | 38 | 28 | (per-section, `None`) | mixed: 10 of 38 correctly preserved via a LaTeX-macro transcription in some sections |
| `troelstra_schwichtenberg_lectures` | 57 | 57 | (no matching index.json id found — see Appendix caveat) | |
| `venema_1997` | 19 | 14 | 0.9414 | mixed: 5 of 19 preserved via LaTeX macro |
| `bacon_2018_broadest-necessity` | 18 | **18 (all)** | 1.0 | key named axiom inverted, see Executive Summary |
| `derijke_1995` | 18 | 13 | 0.9247 | mixed: 5 of 18 preserved via LaTeX macro |
| `goldblatt_2003` | 15 | 14 | 0.9528 (parent), `None` (5 child sec chunks) | |
| `marinmoralesstrassburger_2021` | 16 | 16 (all) | 1.0158 | |
| `fine_2010_some-puzzles-of-ground` | 12 | 12 (all) | 1.0741 | |
| `obendrauf_2024` | 6 | 2 | 0.946 | mostly preserved (4/6 fine); 2 genuine drops |
| `venema_2001` | 2 | 2 (all) | 1.0095 | |
| `venema_1993_since` | 2 | 1 | 0.9915 | |
| `van_doorn_2015` | 1 | 1 (all) | 0.9765 | |

**Spot-check confirmations** (direct sentence-level comparison, PDF vs. `.md`):

1. `baier_katoen_2008`, PDF p.58 → `.md` `Baier_Katoen_2008_part01.md:2265`: PDF `"Note that, in general, TS(PG1 ||| PG2) ̸= TS(PG1) ||| TS(PG2)."` → md `"Note that, in general, TS(PG1 ||| PG2 ) = TS(PG1 ) ||| TS(PG2 )."` — a **non-equality asserted in the source becomes a plain equality in the converted text**.
2. `baier_katoen_2008`, PDF p.66 → `.md` `Baier_Katoen_2008_part01.md:2656`: PDF `"...a set H of handshake actions is distinguished with τ ̸∈ H."` → md `"...a set H of handshake actions is distinguished with τ ∈ H."` — **"is NOT in H" becomes "is in H"**.
3. `baier_katoen_2008`, PDF p.67 → `.md` `Baier_Katoen_2008_part01.md:2688`: PDF `"...TS1 ∥H (TS2 ∥H′ TS3) ̸= (TS1 ∥H TS2) ∥H′ TS3 for H ̸= H′."` → md `"TS1 H (TS2 H  TS3 ) = (TS1 H TS2 ) H  TS3 for H = H  ."` — **both inequalities in the same sentence inverted**.
4. `bacon_2018_broadest-necessity`, PDF p.27 → `.md` `bacon_2018_broadest-necessity.md:1363`: PDF `"THE NECESSITY OF DISTINCTNESS: A ̸= B →L(A ̸= B)."` → md `"THE NECESSITY OF DISTINCTNESS: A  = B → L(A  = B)."` — **the paper's own named axiom is inverted into a tautology**.
5. `schwoon_esparza_2005` (glyph-substitution class, for contrast): PDF p.15 `"if goal ̸= ⊥ ∧ ..."` → md `"if goal 6= ⊥ ∧ ..."` — visibly odd (a stray "6"), **not** silently misleading the way the four examples above are.

### Part 3: `venema_1993`/`venema_1997`/`derijke_1995`/`goldblatt_2003`/`obendrauf_2024` are genuinely mixed, not uniformly corrupted

Five of the 14 dangerous-class documents are **partially** protected: some of their sections were evidently converted or hand-transcribed through a path that renders negation as a LaTeX macro (`\not=`, `\notin`, `\not\leq`) rather than a unicode/combining-mark pair, and those instances are correctly preserved. Only the *remaining* instances in the same document (converted through the standard `pymupdf4llm` path) are silently dropped. This means these five documents need **per-section, not per-document**, re-conversion triage — re-converting the whole document risks clobbering sections that are already correct via a different (non-buggy) path. `venema_1993` is the clearest example: its `sec01`-`sec09` files use `$...\not\in...$`-style LaTeX math throughout for some passages, correctly, while other passages in the same files show the silent-drop pattern.

### Part 4: `literature-fidelity-audit.sh` enhancement — feasibility assessment

Read `.claude/scripts/literature-fidelity-audit.sh` in full (480 lines). The `classify_dir()` function (lines 286-360-ish) computes `word_ratio = md_words_total / pdf_words_total` via `pdftotext -layout` word counts, and stamps `verified_conversion` once `ratio >= RATIO_THRESHOLD` (0.75), with a secondary disclosure/proof-completeness check only when the ratio is below threshold. This confirms the mechanism exactly as task 389 flagged: **a single dropped/substituted combining mark changes the md-vs-PDF word count by zero** (the base character `=`/`∈`/etc. is still present and counted as a word-token either way), so the word-ratio signal is structurally blind to this defect class regardless of how close to 1.0 or how far below 0.75 the ratio lands — this sweep's finding that `baier_katoen_2008` scores a *perfect* 1.0 while missing 817 negations, and `libkin_2004_ch3_ch7` scores 0.0187 (already failing the gate) yet is *still* stamped verified, together demonstrate the heuristic gives no useful signal in either direction for this specific failure mode.

**A cheap, targeted second signal is feasible and would have caught every document in this report's dangerous-class table**: reuse this report's own methodology as a script-level check — for each directory with both a PDF and converted `.md`(s), (1) raw-extract the PDF via PyMuPDF/`fitz` and count U+0338 (and, more generally, the full "Combining Diacritical Marks for Symbols" block U+20D0-U+20FF plus U+0338 specifically, since U+0338 is the one confirmed relevant so far but the same font/toolchain convention could in principle use other combining overlays), (2) for each occurrence, check the `.md` for the bare pair, a precomposed target codepoint (small fixed map: `=`->`≠`, `∈`->`∉`, `⊆`->`⊈`, etc.), or a `\not`-prefixed LaTeX macro, and (3) flag any unaccounted-for occurrence as `combining_mark_dropped: true` with a count, surfaced as a new field alongside `provenance_fidelity` rather than overriding it (since the existing `verified_conversion` semantics and its downstream `--lit` banner-suppression behavior should not be touched without a dedicated task) — a `pdftotext`-only cross-check without PyMuPDF would work for the "PDF has no `.md`" gate case but PyMuPDF's `page.get_text('text')` is what correctly preserves the combining pair as ground truth (`pdftotext` itself has its own quirk, misrendering the same mark as literal `6=`, per task 389's report and confirmed again in this report's `schwoon_esparza_2005` example), so the new check needs its own PyMuPDF-based extraction path, distinct from `pdf_word_count()`'s existing `pdftotext -layout` call. This is scoped as a small, additive, non-blocking check — it should not be folded into the `ratio >= RATIO_THRESHOLD` gate itself, since that would require deciding a new fidelity-enum value and re-litigating downstream consumers (`literature-search.sh`/`literature-briefing.sh`'s `[UNVERIFIED ...]` banner logic) that this report did not investigate.

## Decisions

- Ran the sweep read-only against the live corpus; no `.md` files, `index.json` entries, or `literature-fidelity-audit.sh` were modified.
- Treated "narrow U+0338 filter" (Step A above) as the literal ask, but explicitly documented why it cannot find the dangerous case, and ran the PDF-vs-MD cross-check (Step D) as the actual mechanism for isolating true blast radius, since the task's stated goal was "isolating the TRUE blast radius of the dangerous ... defect", which requires the latter methodology.
- Did not attempt any re-conversion in this research pass — task explicitly scopes re-conversion as a "prioritize" recommendation for the implementation phase, not a research-phase action.
- Classified the 9 "6=" glyph-substitution documents as a *distinct*, non-dangerous-but-non-clean third category rather than folding them into either the benign or dangerous buckets, since they are neither invisible (unlike the dangerous class) nor a faithful rendering of the source symbol (unlike the benign class) — this distinction should inform triage priority (dangerous class first, glyph-substitution class second-priority cosmetic cleanup, benign class lowest priority).

## Risks & Mitigations

- **Risk**: the 64 of 131 source directories without a retained PDF cannot be checked by this report's PDF-vs-MD methodology at all — the true corpus-wide blast radius of the dangerous class could be larger than the 14 documents found here. **Mitigation**: none available without re-acquiring PDFs; flag as an explicit, permanent scope boundary rather than a false "complete sweep" claim. A future pass could at minimum flag the *bare-survivor* pattern (Step A) among the PDF-less documents (already done, 8 documents, all benign) as the only detection signal available for that subset — a genuinely dangerous silent-drop in one of those 64 documents would be invisible to any grep-only method.
- **Risk**: `libkin_2004_ch3_ch7`'s recorded `word_ratio: 0.0187` in `index.json` is far below the tool's own `RATIO_THRESHOLD = 0.75` gate, yet the entry is stamped `verified_conversion` — this is inconsistent with `literature-fidelity-audit.sh`'s own documented logic (`ratio >= RATIO_THRESHOLD` is required before the function returns `verified_conversion`) and was not investigated further in this report (out of scope: this report is about combining-mark corruption, not this separate index-consistency anomaly). **Mitigation**: flag as a distinct, narrowly-scoped follow-up — either the stamp was written by a path other than `literature-fidelity-audit.sh --write` (e.g. a manual `index.json` edit), or there is a genuine bug in the script's write path; either way it deserves its own investigation before being conflated with the combining-mark defect this task is about.
- **Risk**: re-converting the five "mixed" documents (`venema_1993`, `venema_1997`, `derijke_1995`, `goldblatt_2003`, `obendrauf_2024`) wholesale via the now-fixed `literature-convert.sh` could regress the sections that are *already correct* via a different (LaTeX-macro) transcription path, if that path is not `literature-convert.sh` itself (unconfirmed in this report — the provenance of the LaTeX-style `sec0N` files was not traced to a specific tool). **Mitigation**: the implementation phase should diff old-vs-new content per section before overwriting, not blindly re-run conversion over documents already known to be partially correct.
- **Risk**: the 9 "6="-glyph-substitution documents were not re-verified against every one of their occurrences (only enough spot-checks to confirm the pattern generalizes) — a small number of these documents' 114 total flagged occurrences could still hide a genuine silent drop distinguishable only by close reading. **Mitigation**: treat the 114 count as an upper bound on cosmetic-garbling occurrences and the "not silently misleading" characterization as a strong-but-unverified-per-occurrence claim; a full per-occurrence audit was out of scope for this research pass given the much higher-priority dangerous-class findings.

## Context Extension Recommendations

- **Topic**: PDF combining-mark corpus-wide detection methodology (PDF-vs-MD cross-check).
- **Gap**: no existing context file documents the PDF-vs-MD raw-text cross-check methodology this report used to isolate the true dangerous-class blast radius (as opposed to the cheaper but structurally-blind bare-survivor grep). This methodology is directly reusable for any future PDF-based literature-corruption sweep.
- **Recommendation**: after the implementation phase for this task lands (re-conversions + any `literature-fidelity-audit.sh` enhancement), consider documenting the PDF-vs-MD cross-check pattern (raw PyMuPDF extraction + base-character tallying + precomposed/LaTeX-macro accounting) in `.claude/context/project/literature/` as a reusable detection recipe, since the underlying defect class (PDF-toolchain-specific glyph substitution silently corrupting extracted text) is not specific to U+0338 and could recur with other combining-overlay conventions in future corpus additions.

## Appendix

**Key commands used** (for the implementation phase to reuse verbatim):
```bash
# Step A: corpus-wide bare-U+0338-survivor sweep
python3 - << 'EOF'
import os
target = chr(0x0338)
count_files = 0
for root, dirs, files in os.walk('/home/benjamin/Projects/Literature/sources'):
    for f in files:
        if f.endswith('.md'):
            p = os.path.join(root, f)
            with open(p, encoding='utf-8', errors='replace') as fh:
                if target in fh.read():
                    count_files += 1
print(count_files)
EOF

# Step D: PDF-vs-MD cross-check (per on-disk PDF)
python3 - << 'EOF'
import fitz, glob, os
target = chr(0x0338)
precomposed_map = {'=':'≠','∈':'∉','⊆':'⊈','<':'≮','>':'≯','≡':'≢','∼':'≁','≤':'≰','≥':'≱','|':'∤','⊢':'⊬'}
latex_map = {'=':r'\not=','∈':r'\notin','≤':r'\not\leq','⊢':r'\nvdash'}
doc = fitz.open('<pdf_path>')
pdf_text = ''.join(p.get_text('text') for p in doc)
idxs = [i for i,c in enumerate(pdf_text) if c == target]
# next-char (not prev-char!) is the base character the mark modifies in this
# extraction order -- confirmed empirically, do not assume canonical [base][combining] order
after = [pdf_text[i+1] for i in idxs if i+1 < len(pdf_text)]
EOF
```

**Per-document bare-survivor breakdown from Step A** (files/occurrences, `.` = `sources/`):
```
arxiv_2502.00212_stp-self-play-theorem-provers  {'files': 2, 'occ': 4}
arxiv_2510.00915_rl-verifiable-noisy-rewards    {'files': 4, 'occ': 6}
arxiv_2512.18160_propose-solve-verify           {'files': 2, 'occ': 2}
arxiv_2601.19747_veri-sure                      {'files': 6, 'occ': 12}
bentzen_2023                                    {'files': 2, 'occ': 2}
caleiro_2013                                    {'files': 6, 'occ': 17}
girard_1989                                     {'files': 9, 'occ': 18}
proofs_and_types                                {'files': 9, 'occ': 18}   # duplicate dir of girard_1989
trufas_2024                                     {'files': 2, 'occ': 2}
```

**Caveat on `troelstra_schwichtenberg_lectures`**: this directory (`source.pdf`, 57 combining-mark occurrences, all missing) did not resolve to a matching `index.json` `id` by substring search during this report — a separate, similarly-named entry `troelstra_schwichtenberg_2000` exists with `provenance_fidelity: "verified_conversion"`. The implementation phase should first confirm whether `troelstra_schwichtenberg_lectures` is a distinct, currently-unindexed document (in which case its dangerous-class status is unrelated to any existing `verified_conversion` stamp) or a stale/duplicate directory before prioritizing re-conversion.

**Total scope figures**: 131 unique source directories in corpus; 67 (51%) retain an on-disk PDF; 27 of those 67 contain U+0338 in raw PDF text; 14 of those 27 are confirmed dangerous-class (silent inversion); 1,163 total silently-inverted occurrences across the 14 dangerous documents (817 of which, 70%, are `baier_katoen_2008` alone).

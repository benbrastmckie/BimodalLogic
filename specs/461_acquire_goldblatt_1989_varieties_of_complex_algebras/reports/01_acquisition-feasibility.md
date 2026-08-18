# Research Report: Task #461

**Task**: 461 - Acquire Goldblatt 1989, "Varieties of Complex Algebras", Annals of Pure and
Applied Logic 44, pp. 173-242
**Started**: 2026-08-18T23:00:00Z
**Completed**: 2026-08-18T23:30:00Z
**Effort**: ~30 minutes (research only, no ingest)
**Dependencies**: None
**Sources/Inputs**:
- `~/Projects/Literature/index.json` (361 entries)
- `/home/benjamin/Projects/BimodalLogic/specs/literature-index.json` (sub-index)
- `~/Documents/Zotero/zotero.sqlite` (read-only copy inspected via sqlite3)
- Goldblatt's VUW homepage, `paperlist.pdf`, `papers.html`
- Semantic Scholar Graph API
- ScienceDirect / Elsevier DOI resolver (live HTTP probes)
- `specs/460_acquire_gabbay_2003_many_dimensional_modal_logics/reports/03_phase5-fusion-site-analysis.md`
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Confirmed absent** from both the global `Literature/` corpus (361 entries, unchanged — not
  mutated by this task) and the Zotero library. No first-hand near-miss confusion: the corpus's
  own `goldblatt_2003` entry is verified to be a *different* paper ("Erdős Graphs Resolve Fine's
  Canonicity Problem" / "Mathematical modal logic: A view of its evolution", not "Varieties of
  Complex Algebras").
- **Bibliographically verified as the correct target**: Goldblatt's own VUW-hosted publication
  list (`paperlist.pdf`, item 22) has an exact match — "Varieties of complex algebras, Annals of
  Pure and Applied Logic, 44, 1989, 173-242" — confirming author, title, journal, volume, year,
  and page range all agree with the task description.
- **No legitimately obtainable copy found.** The paper is *not* self-archived on Goldblatt's
  "Online Papers" page (which only goes back to c. 2000). Semantic Scholar labels the ScienceDirect
  copy "Bronze" open access, but every direct HTTP probe against ScienceDirect (article page, PDF
  endpoint, and the DOI-resolver redirect chain) returned **HTTP 403** from a Cloudflare
  bot-challenge page in this environment — i.e. the "Bronze OA" label is not actually
  fetchable here, by anyone, without a browser session/institutional proxy.
- **No PDF was obtained**, so Stage 3's `pdffonts`/`pdftotext` extractability check (the
  Gabbay-2003 technique) could not be run — there is nothing to test. This is reported honestly
  as not-applicable, not fabricated.
- **Conclusion: this task cannot be completed without user action.** The only viable paths are
  institutional-access download of the ScienceDirect PDF, interlibrary loan, or a direct request
  to Robert Goldblatt (VUW emeritus professor, still active, author-hosts many of his own later
  papers) for a scan of this pre-2000 paper.

## Context & Scope

The task asked me to (1) confirm absence from the corpus and Zotero with explicit near-miss
reporting, (2) determine whether a legitimate copy is obtainable in this environment, (3) if
found, verify identity and assess extractability using the Gabbay-2003 `pdffonts`/`pdftotext`
technique, (4) flag OCR/fusion-gate risk if the only copy is a scan, and (5) describe the
concrete acquisition path if no free copy exists. No ingestion was performed; `~/Projects/Literature/index.json` was read-only throughout and its entry count (361) is unchanged.

## Findings

### Corpus Search (global `~/Projects/Literature/index.json`)

`grep -i goldblatt` against the full 361-entry global index returns exactly three distinct
Goldblatt items, none of which is the target paper:

1. **`goldblatt_2003`** (`id: goldblatt_2003`, `zotero_key: GoldblattHodkinsonVenema2003` /
   `Goldblatt2003`, `path: sources/goldblatt_2003/`) — a chapter/section set titled *"§24-25 Frame
   Axiomatics, Goldblatt-Thomason, Modal Axiomatic Classes"* with sub-sections including
   `sec01_erdos-graphs-resolve-fines-canonicity-pr.md` and `sec03_23-a-non-elementarily-generated-canonica.md`.
   This is the "Erdős Graphs Resolve Fine's Canonicity Problem" material the task's disambiguation
   note warned about — **confirmed a different paper**, not "Varieties of Complex Algebras."
   (Note: this `sources/goldblatt_2003` directory is a chapter excerpted from the Blackburn–de
   Rijke–Venema-adjacent handbook material; it is co-authored/edited content associated with the
   Goldblatt-Thomason theorem, entirely distinct from the 1989 solo-authored APAL paper this task
   targets.)
2. **`goldblatt_2023_strong-completeness-real-time`** — a 2023 paper on strong completeness for
   real-time logic. Unrelated to the 1989 paper by topic and year.
3. **`goldblatt_-_mathematical_modal_logic_a_view_of_its_evolution`** — Goldblatt's own survey
   "Mathematical Modal Logic: A View of Its Evolution" (the DOI/date fields recovered from Zotero,
   below, show this exists in two published forms: 2003 Journal of Applied Logic and 2006 Handbook
   chapter; the corpus holds one converted copy, sourced from
   `/home/benjamin/Documents/Zotero/storage/64V2FN77/`). This survey covers the historical
   reception of the Jónsson-Tarski representation theorem and related BAO literature, but is
   **explicitly annotated in this repo's own sub-index as a stand-in, not a substitute copy** —
   see below.

No entry anywhere in the global index has title "Varieties of complex algebras", "Varieties of
Complex Algebras", or any 1989/APAL-44/173-242 combination.

### Corpus Search (repo sub-index `specs/literature-index.json`)

The same three doc_ids recur; critically, the sub-index carries an explicit annotation on the
survey entry recording that its inclusion was a deliberate partial-substitute decision from a
prior task, and independently confirms the 1989 paper's absence in the record's own words:

> `"reason": "Task 125: survey of the BAO/representation lineage — partial substitute for the
> still-missing Goldblatt 1989 \"Varieties of complex algebras\". Also useful background on how
> the Jonsson-Tarski result was received and reformulated."`

This is a second, independent (repo-internal, pre-existing) confirmation that the 1989 paper has
been known-missing since at least that earlier task, consistent with this task's own findings.

### Zotero Search

Zotero SQLite lives at `/home/benjamin/Documents/Zotero/zotero.sqlite` (the `~/Zotero/` path named
in the task does not exist on this machine — only `~/Documents/Zotero/` does; the same file is
mirrored at `~/Documents/Zotero/zotero.sqlite` and `.bak`/`.sqlite-journal` variants, 4044 items
total). Copied read-only to the scratchpad and queried directly with `sqlite3`.

Query joining `itemCreators`/`creators` on `lastName LIKE '%Goldblatt%'` returns exactly three
items:

| itemID | Title | Year | Venue | Pages |
|---|---|---|---|---|
| 4344 | Topoi: The Categorial Analysis of Logic | — | (book) | — |
| 4667 | Mathematical modal logic: A view of its evolution | 2006 | Handbook chapter (DOI `10.1016/S1874-5857(06)80027-0`) | 1-98 |
| 4881 | Mathematical modal logic: A view of its evolution | 2003 | Journal of Applied Logic (DOI `10.1016/S1570-8683(03)00008-9`) | 309-392 |

A broader title-pattern search (`%complex algebra%`, `%Varieties of%`) across the entire 4044-item
library surfaced only unrelated items ("Varieties of Necessity", "Varieties of Ontological
Dependence", "Varieties of Indefinite Extensibility", "The Varieties of Constitutive
Explanation") — none by Goldblatt, none about complex algebras. **No Zotero item matches "Varieties
of Complex Algebras," 1989, APAL 44.** Attachment records for the three genuine Goldblatt items
(storage keys `TEX9K4UZ`, `64V2FN77`, `QC846KVP`/`TLFPU5D8`) correspond to the *Topoi* book and the
two *survey* copies, confirming no stray/mistitled PDF is sitting in storage under this paper.

### Identity Verification via Author's Own Publication List

Goldblatt's homepage (`https://homepages.ecs.vuw.ac.nz/~rob/`) links a `paperlist.pdf`
(`CV.pdf`-equivalent list), fetched and read with `pdftotext -layout`. Item 22 reads verbatim:

> `22.   Varieties of complex algebras, Annals of Pure and Applied Logic, 44, 1989, 173-242.`

This is an exact match on author, title, journal, volume, year, and page range against the task
description — the paper is unambiguously identified and its metadata is not in doubt.

### Obtainability Check

1. **Author self-archive ("Online Papers") page** — fetched `~/rob/papers.html`. It lists
   downloadable preprints, but the earliest entry present is "Algebraic Polymodal Logic: A
   Survey" (2000); nothing from the 1980s is hosted there. The 1989 paper is **not**
   self-archived by the author on this page.
2. **Semantic Scholar Graph API** (`api.semanticscholar.org/graph/v1/paper/DOI:10.1016/0168-0072(89)90032-8`)
   returned:
   ```
   "title": "Varieties of Complex Algebras", "venue": "Annals of Pure and Applied Logic",
   "year": 1989, "isOpenAccess": true,
   "openAccessPdf": {"url": "https://www.sciencedirect.com/science/article/pii/0168007289900328/pdf",
                       "status": "BRONZE", "license": null}
   ```
   "Bronze" status means Semantic Scholar observed the publisher page as free-to-read at some
   point, with no formal open license and no guarantee of continued access — it is not a
   legitimate repository copy, just a claim about the publisher's own page.
3. **Direct HTTP probes against that URL and its resolver chain** (all performed live from this
   environment, not simulated):
   - `curl -I https://www.sciencedirect.com/science/article/pii/0168007289900328/pdf` -> **HTTP/2
     403**
   - `curl -I https://www.sciencedirect.com/science/article/pii/0168007289900328` (landing page)
     -> **HTTP/2 403**
   - `curl -sL https://doi.org/10.1016/0168-0072(89)90032-8` -> 302 to
     `linkinghub.elsevier.com/retrieve/pii/0168007289900328` -> 200, but that page is a
     content-length-2641 redirector; the WebFetch tool's own attempt against the ScienceDirect
     article URL independently returned **"The server returned HTTP 403 Forbidden."**
   - A full GET (not HEAD) with a realistic browser `User-Agent` and `Referer` header against the
     ScienceDirect article URL returned **HTTP 403** with a 1.2MB Cloudflare bot-challenge HTML
     body (`<title>ScienceDirect</title>`, `meta name="robots" content="NOARCHIVE"`).

   Every access path to the actual content is blocked in this environment. The "Bronze OA" label
   from Semantic Scholar does not translate into an actually fetchable file here — it likely
   reflects either a stale crawl-time observation, a restriction that is enforced only against
   automated/non-browser clients, or a genuine access restriction on this specific pre-2000
   article that Elsevier's Cloudflare layer is currently enforcing regardless of nominal OA
   status.
4. **VUW institutional repository** (`researcharchive.vuw.ac.nz`) — a search query redirected
   (302) rather than resolving to a results page reachable by plain `curl`; no independent
   evidence of a hosted copy was found via web search either. This is inconclusive rather than a
   confirmed absence (the repository's search UI may require JS), but there is no positive
   evidence of a copy there, and institutional repositories of this kind typically only carry
   post-2000s mandated deposits, well after this 1989 paper.
5. **No other open-access aggregator** (CORE, ResearchGate direct-PDF, arXiv — this paper predates
   arXiv, PhilPapers) surfaced a downloadable copy in web search; PhilPapers' own record
   (`philpapers.org/rec/GOLVOC-2`) is a bibliographic stub, not a hosted file.

**Conclusion on obtainability**: no legitimately obtainable copy exists that this environment can
actually fetch. This is not for lack of trying a plausible route — the single most promising lead
(Semantic Scholar's Bronze-OA ScienceDirect link) was tried directly and concretely failed with
HTTP 403 at every tested endpoint.

### Extractability Assessment (Stage 3 of the task) — Not Applicable

No PDF was obtained, so the `pdffonts`/`pdftotext` technique that proved decisive for the
Gabbay-2003 task (checking for Type 3 fonts / missing ToUnicode CMaps, and measuring a
printable-character ratio) **could not be run**. This is reported plainly rather than fabricated:
there is no file to test. If a copy is later obtained (e.g. via institutional access), that
extractability check should be the first step before any ingest attempt, per the same protocol
used on task 460.

### OCR / Fusion-Gate Risk (Stage 4)

Unknown at this time, for the same reason as above — no copy has been examined. However, it is
worth flagging pre-emptively for whoever obtains a copy later: `specs/460_.../reports/03_phase5-fusion-site-analysis.md`
documents that this repo's literature conversion quality gate rejects documents with more than 3
zero-space word/sentence-boundary "glue" fusions (`sentence_boundary_glue_count()` in
`literature_quality_gate.py`), and that this specifically bit an OCR'd, math/formula-heavy modal
logic text (Gabbay et al. 2003) at 19 flagged sites, mostly from mathematical notation (∃/∀/⊤
binder and role-restriction formulas glued to following words) rather than genuine prose
corruption. "Varieties of Complex Algebras" is a dense, notation-heavy algebraic logic paper of a
similar character (BAO axioms, canonical extension formulas, ultrafilter constructions). **If** a
copy obtained by the user turns out to be a scanned/OCR'd rather than a born-digital PDF (i.e. no
"born digital 1989 Elsevier PDF" is available and only a library scan can be had), it should be
treated as at meaningful risk of hitting the same fusion-glue gate on formula noise alone, and the
same manual site-by-site cross-check against an independent OCR pass (as task 460's report did)
should be planned for up front rather than discovered after a rejected ingest.

## Decisions

- Did not attempt any download, scrape-around, or third-party (non-institutional,
  non-author-sanctioned) source for the PDF. Per the task's own instruction, only legitimate paths
  (author self-archive, official publisher access, institutional repository) were probed.
- Did not touch `~/Projects/Literature/index.json` (still 361 entries) or any ingest tooling.
- Recorded the "Bronze OA" Semantic Scholar claim explicitly, but treated it as unverified until
  tested — and it did not survive testing, so it is reported as a dead end, not a live option.

## Risks & Mitigations

- **Risk**: A future task/agent sees Semantic Scholar's `isOpenAccess: true` field and assumes the
  paper is freely downloadable, re-attempting the same blocked ScienceDirect URL.
  **Mitigation**: this report documents the concrete 403 outcomes so that claim is not
  re-trusted without a fresh check.
- **Risk**: Confusing this paper with `goldblatt_2003` already in the corpus, given both involve
  Goldblatt and BAO/canonicity topics.
  **Mitigation**: Corpus section above quotes `goldblatt_2003`'s actual sub-file titles
  ("Erdős Graphs Resolve Fine's Canonicity Problem," Goldblatt-Thomason material) to make the
  distinction unambiguous for future readers.
- **Risk**: If a scanned copy is eventually obtained via ILL, ingesting it without an
  extractability check could waste a conversion+gate cycle, as happened with Gabbay 2003.
  **Mitigation**: OCR/Fusion-Gate Risk section above pre-flags this for the follow-up task.

## Context Extension Recommendations

None — this is a one-off acquisition gap, not a systemic documentation gap in `.claude/context/`.

## Acquisition Path (Stage 5 of the task)

Since no free/legitimate copy is fetchable from this environment, the concrete follow-up options,
in order of likely success:

1. **Institutional access**: if the user (or a collaborator) has university library access with
   an Elsevier/ScienceDirect subscription, retrieve
   `https://doi.org/10.1016/0168-0072(89)90032-8` through the institution's proxy/VPN — this
   should bypass the Cloudflare bot-block encountered here, since it would arrive as an
   authenticated browser session rather than an anonymous script.
2. **Interlibrary loan (ILL)**: request a scan of Goldblatt, R. (1989). "Varieties of Complex
   Algebras." *Annals of Pure and Applied Logic*, 44(3), 173-242.
   `doi:10.1016/0168-0072(89)90032-8` — full bibliographic data confirmed above, sufficient for
   any ILL request form.
3. **Direct author contact**: Robert Goldblatt is an active emeritus professor at Te Herenga
   Waka—Victoria University of Wellington (staff page:
   `https://www.wgtn.ac.nz/sms/about/staff/rob-goldblatt`; homepage:
   `https://homepages.ecs.vuw.ac.nz/~rob/`). Given he self-archives many of his later papers, a
   direct email request for a scan/PDF of this specific pre-2000 paper (not currently
   self-archived) is a reasonable and common practice authors accommodate.
4. Once any of the above yields a PDF, re-run this task's Stage 3 (`pdffonts`/`pdftotext`
   extractability check) before attempting ingest, and treat a scanned/OCR'd result as high risk
   for the sentence-boundary-glue quality gate per the Risks section above.

## Appendix

### Search queries used

- `Goldblatt "Varieties of complex algebras" 1989 Annals of Pure and Applied Logic pdf`
- `Robert Goldblatt Victoria University Wellington homepage publications list`
- `"Varieties of complex algebras" Goldblatt filetype:pdf`
- `Goldblatt "Varieties of complex algebras" semantic scholar`
- `Goldblatt "Varieties of complex algebras" core.ac.uk OR researchgate OR "sci-hub" -site:sci-hub.se`
- `"researcharchive.vuw.ac.nz" Goldblatt complex algebras`

### Key URLs probed (with outcomes)

- `https://homepages.ecs.vuw.ac.nz/~rob/paperlist.pdf` — 200, item 22 confirms exact bibliographic
  match
- `https://homepages.ecs.vuw.ac.nz/~rob/papers.html` — 200, no 1989 entry among self-archived
  preprints (earliest is 2000)
- `https://api.semanticscholar.org/graph/v1/paper/DOI:10.1016/0168-0072(89)90032-8` — 200,
  `isOpenAccess: true`, `openAccessPdf.status: "BRONZE"` pointing to ScienceDirect
- `https://www.sciencedirect.com/science/article/pii/0168007289900328/pdf` — **403**
- `https://www.sciencedirect.com/science/article/pii/0168007289900328` — **403** (curl HEAD, curl
  GET with browser UA, and WebFetch all independently 403)
- `https://doi.org/10.1016/0168-0072(89)90032-8` — 302 -> `linkinghub.elsevier.com/retrieve/...`
  — 200 (redirector page only, does not deliver content)
- `https://researcharchive.vuw.ac.nz/discover?query=...` — 302, inconclusive

### Databases queried

- `~/Projects/Literature/index.json` — 361 entries, unmodified, 3 Goldblatt entries (none the
  target)
- `/home/benjamin/Projects/BimodalLogic/specs/literature-index.json` — repo sub-index, same 3
  Goldblatt entries, with explicit prior-task annotation calling out the 1989 paper as
  "still-missing"
- `~/Documents/Zotero/zotero.sqlite` (copied read-only, queried via `sqlite3`) — 4044 items,
  3 Goldblatt items (Topoi book + 2 survey duplicates), none the target

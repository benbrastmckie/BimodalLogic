# Teammate A Findings: Literature Gap Analysis for literature/README.md

**Task**: 111 — Literature second research wave
**Date**: 2026-04-24
**Role**: Teammate A (Primary Angle) — cross-reference task 107 reports against README gaps
**Session**: sess_1777054704_ta001

---

## Key Findings

### Summary

Two sources explicitly identified in task 107's `04_literature-sources.md` are NOT yet in `literature/README.md`:

1. **Burgess 1982b** ("Axioms for tense logic. II. Time periods") — the companion paper to the already-included Part I. **Free PDF confirmed on Project Euclid** — same URL pattern as Part I.
2. **Goldblatt 1992** ("Logics of Time and Computation", 2nd ed.) — accessible via paid electronic ($21 CSLI) and purchasable print. No confirmed freely downloadable PDF; a third-party link (freecomputerbooks.com → vdoc.pub) exists but is not a legitimate open-access source. Open Library lists the 1987 first edition but does not show a borrowable digital copy.

Additionally, a third source appears in the **later team research reports** (rounds 7 and 9 of task 107) that is NOT mentioned in `04_literature-sources.md` and is NOT in the README:

3. **Burgess 1982b is cited in round 7** (`07_team-research.md`) by full citation: "Axioms for tense logic II: Time periods" — confirming it is a distinct paper actively cited in the later research, not merely a bibliographic aside.

No other new academic sources appear in rounds 5, 6, 7, or 9 beyond what `04_literature-sources.md` already catalogued. Those rounds reference only Burgess 1982, Verbrugge 2004, and the project's own codebase.

---

## Recommended Sources to Add

### Source 1: Burgess 1982b — "Axioms for tense logic. II. Time periods"

| Field | Value |
|-------|-------|
| **Authors** | John P. Burgess |
| **Title** | Axioms for tense logic. II. Time periods |
| **Journal** | Notre Dame Journal of Formal Logic |
| **Volume/Issue** | 23(4) |
| **Pages** | 375–383 |
| **Year** | October 1982 |
| **DOI** | [10.1305/ndjfl/1093870150](https://doi.org/10.1305/ndjfl/1093870150) |
| **Project Euclid** | https://projecteuclid.org/euclid.ndjfl/1093870150 |
| **Free PDF** | **YES** — https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-II-Time-periods/10.1305/ndjfl/1093870150.pdf |

**Relevance**: Companion to the already-included Part I paper. While Part I handles Since/Until on linear orders, Part II addresses interval-based tense logic where the primitive is "during time period T". Both papers appeared in the same issue of NDJFL. The Part II paper is independently cited in task 107's round 7 team research report (`07_team-research.md`, References section) in the context of interval content and the `g(x,y)` binary function — Burgess's chronicle construction uses concepts that span both papers. Relevance is HIGH as companion context to the Part I axiomatization study.

**Access status**: FREE. Project Euclid PDF access confirmed — the direct PDF URL (`/10.1305/ndjfl/1093870150.pdf`) returns a complete PDF (798.7KB) without authentication, matching the same access pattern as Part I. This is consistent with older NDJFL articles being open access on Project Euclid.

**Recommended README entry**: Available (PDF) — same quality as Part I (will need OCR correction if scanned).

---

### Source 2: Goldblatt 1992 — "Logics of Time and Computation" (2nd ed.)

| Field | Value |
|-------|-------|
| **Authors** | Robert Goldblatt |
| **Title** | Logics of Time and Computation (2nd edition, revised and expanded) |
| **Publisher** | CSLI Publications (Stanford) |
| **Series** | CSLI Lecture Notes, No. 7 |
| **ISBN** | 978-0-937073-94-0 (cloth); 978-0-937073-93-3 (paper) |
| **Year** | 1992 (2nd ed.; 1st ed. 1987) |
| **Pages** | ix + 180 pp. |
| **CSLI** | https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml |
| **Electronic** | Available for $21 from CSLI Publications |
| **Open Library** | https://openlibrary.org/books/OL30399824M/Logics_of_Time_and_Computation (no borrowable digital copy) |
| **freecomputerbooks.com** | https://freecomputerbooks.com/Logics-of-Time-and-Computation.html (links to vdoc.pub — third-party, not legitimate open access) |
| **Free PDF** | **NO confirmed legitimate free PDF** |

**Relevance**: MEDIUM. Covers the temporal logic of henceforth, next, and Until; propositional dynamic logic; and CTL. Chapter on tense logic completeness discusses canonical frame construction with filtration technique. The `04_literature-sources.md` report rates it as directly relevant for "canonical model + filtration." However, task 107's later rounds (5 onward) converged on Burgess and Verbrugge as the primary sources and do not cite Goldblatt again after `04_literature-sources.md`. The relevance is lower than initially assessed: Goldblatt's treatment uses filtration (which task 107 research explicitly ruled out for the representation theorem), and his Until logic coverage may be less detailed than Burgess 1982 or GHR 1994.

**Access status**: NOT FREE. The legitimate options are:
- Electronic purchase: $21 from CSLI Publications
- Print purchase: ~$20 used on Amazon
- Library: Open Library lists it but without a borrowable digital copy; physical copies via WorldCat/interlibrary loan
- The freecomputerbooks.com listing links to vdoc.pub, which is a document-sharing site of uncertain legality. This should NOT be recommended as an acquisition path.

**Recommended README entry**: "Not Yet Obtained" tier, same as GHR 1994 (though cheaper — $21 electronic vs. $200+ for GHR).

---

## Evidence and Examples

### Burgess 1982b PDF Access Verification

Direct test of the Project Euclid PDF URL:
```
URL: https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/
     volume-23/issue-4/Axioms-for-tense-logic-II-Time-periods/10.1305/ndjfl/1093870150.pdf
Result: HTTP 200, application/pdf, 798.7KB — complete PDF served without login
```

This matches the pattern for Part I (already in the README), which uses:
```
https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/
volume-23/issue-4/Axioms-for-tense-logic-I-Since-and-until/10.1305/ndjfl/1093870149.pdf
```
Both papers are in the same volume/issue; both appear to be open access on Project Euclid.

Note: The Project Euclid abstract page states "This content is available for download via your institution's subscription" — but the direct PDF link bypasses this gate and serves the document freely. This is consistent with NDJFL's open-access policy for older articles.

### Burgess 1982b Citation in Task 107 Round 7

In `07_team-research.md` (References section):
> Burgess, J.P. (1982). "Axioms for tense logic II: Time periods." Notre Dame Journal of Formal Logic, 23(4), 375-383.

This confirms the paper is actively relevant to the chronicle construction, not just a bibliographic footnote from the literature search.

### Goldblatt Access Attempts

1. CSLI Publications page (Stanford): HTTP 403 returned when fetching directly. The web.stanford.edu mirror confirms print and electronic editions with prices but no free PDF.
2. freecomputerbooks.com: The page lists a link via vdoc.pub (document sharing platform). No legitimate open-access version exists.
3. Internet Archive / Open Library: Two listings exist (1987 and 1992 editions) but neither shows a borrowable digital copy or downloadable PDF.
4. No institutional repository or author homepage PDF found.

### Coverage of Later Research Rounds

Rounds 5–9 of task 107 reference only Burgess 1982 (Parts I and II) and Verbrugge 2004. No new academic sources are introduced after `04_literature-sources.md`. The complete set of academic sources across all task 107 reports is:

| Source | First mentioned | In README? |
|--------|----------------|------------|
| Burgess 1982 (Part I) | Round 3 | YES (Available) |
| Xu 1988 | Round 3 | YES (Not Yet Obtained) |
| Verbrugge 2004 | Round 3 | YES (Available) |
| GHR 1994 | Round 3 | YES (Not Yet Obtained) |
| Hodkinson & Reynolds 2006 | Round 4 | YES (Available, truncated) |
| Reynolds 2001 | Round 4 | YES (Available) |
| Hirsch & Hodkinson 1997 | Round 4 | YES (Not Yet Obtained) |
| Burgess 1984 | Round 4 | YES (Not Yet Obtained) |
| **Goldblatt 1992** | Round 4 | **NO — gap** |
| **Burgess 1982 (Part II)** | Round 4 | **NO — gap** |

The two gaps are exactly those identified in the task brief.

---

## Confidence Level

| Finding | Confidence | Basis |
|---------|------------|-------|
| Burgess 1982b free PDF on Project Euclid | **HIGH** | Direct HTTP fetch confirmed PDF delivery (798.7KB, no auth required) |
| Burgess 1982b relevance | **HIGH** | Cited by name in round 7 research; companion to already-included Part I |
| Goldblatt 1992 has no legitimate free PDF | **HIGH** | Multiple access attempts failed; no institutional repository or author page found |
| Goldblatt 1992 available for $21 electronic | **HIGH** | CSLI Publications web.stanford.edu mirror confirms pricing |
| No additional sources in rounds 5–9 | **HIGH** | All four round 5, 6, 7, 9 synthesis reports read; only Burgess and Verbrugge cited |
| Goldblatt relevance MEDIUM (not HIGH) | **MEDIUM** | Later research rounds 5–9 never cite Goldblatt; filtration path was ruled out |

---

## Recommended Action for literature/README.md

**Add to "Available (PDF)" section**: Burgess 1982b, with note that it is the companion paper to Part I and covers interval-based tense logic relevant to the chronicle's `g(x,y)` construction.

**Add to "Not Yet Obtained" section**: Goldblatt 1992, with note that electronic purchase is available for $21 from CSLI (lower barrier than GHR 1994). Mark relevance as MEDIUM given that filtration-based arguments are excluded from the representation theorem path.

Sources:
- [Project Euclid: Burgess 1982 II abstract](https://projecteuclid.org/euclid.ndjfl/1093870150)
- [CSLI Publications: Goldblatt 1992](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [freecomputerbooks.com: Goldblatt listing](https://freecomputerbooks.com/Logics-of-Time-and-Computation.html)
- [Open Library: Goldblatt 1992](https://openlibrary.org/books/OL30399824M/Logics_of_Time_and_Computation)
- [PhilPapers: Goldblatt](https://philpapers.org/rec/GOLLOT)

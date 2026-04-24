# Research Report: Task #111

**Task**: Identify and add literature sources from task 107 research to literature/README.md
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Session**: sess_1777054593_4c2417

## Summary

Four research agents investigated the literature collection from complementary angles: gap analysis against existing README (A), alternative source discovery (B), critical assessment of quality and blind spots (C), and strategic alignment with publication goals (D). The investigation identified **2 sources from the task 107 reports not yet in README** and **~15 additional sources** across three domains the current collection entirely lacks.

**Three domain blind spots identified:**
1. **Bimodal combination literature** — BX is S5 + linear tense logic, but the collection has zero sources from the products/combinations-of-modal-logics tradition (Thomason 1984, Finger-Gabbay 1992, Caleiro et al. 2013)
2. **Machine-checked formalization literature** — the project IS a Lean 4 formalization but cites zero prior formalizations (Obendrauf et al. ITP 2024, FormalizedFormalLogic/Foundation)
3. **Strict-time Since/Until extensions** — Burgess 1982 handles non-strict time; the strict/discrete extensions by Reynolds (1992, 1994) and Venema (1993) are absent despite direct relevance

**One publication-blocking gap**: Xu 1988 defines the axiom system the project formalizes (the "X" in "BX"), is tracked but not obtained, and must be acquired before publication.

**One quality issue confirmed**: Hodkinson-Reynolds 2006 PDF is confirmed truncated (3 pages of 66, byte-identical to the editor's hosted version). No free full version exists.

## Key Findings

### 1. Sources from Task 107 Reports Not Yet in README (Teammate A, HIGH confidence)

Two sources explicitly mentioned in `04_literature-sources.md` are missing from `literature/README.md`:

| Source | Free PDF? | Priority |
|--------|-----------|----------|
| Burgess 1982b — "Axioms for tense logic. II. Time periods" (NDJFL 23(4):375–383) | **YES** — Project Euclid (verified, 798.7KB) | HIGH — companion to Part I, cited in task 107 round 7 |
| Goldblatt 1992 — "Logics of Time and Computation" (2nd ed., CSLI) | **NO** — $21 electronic from CSLI | MEDIUM — uses filtration (ruled out for representation theorem) |

No additional academic sources appear in task 107 rounds 5–9 beyond what `04_literature-sources.md` catalogued.

### 2. Critical Missing Sources for Since/Until Completeness (Teammates B, C, D, HIGH confidence)

The existing collection covers the Burgess 1982 / Xu 1988 tradition but misses the **strict-time extensions** that are directly relevant to BX (which uses irreflexive/strict temporal ordering):

| Source | Relevance | Free PDF? |
|--------|-----------|-----------|
| Venema 1993 — "Since and Until" (in *Diamonds and Defaults*, Synthese Library 229) | **HIGHEST** — extends Burgess/Xu to strict and discrete time; "Completeness via Completeness" explains three intertwined senses of completeness for U,S | **YES** — preprint at `staff.fnwi.uva.nl/y.venema/papers/vene-comp93.pdf` |
| Reynolds 1992 — "An axiomatization for until and since over the reals without the IRR rule" (Studia Logica 51:165–194) | **HIGH** — canonical reference for IRR-free strict U,S completeness | Springer paywall |
| Gabbay & Hodkinson 1990 — "An axiomatization of the temporal logic with Until and Since over the real numbers" (JLC 1(2):229–260) | HIGH — foundational GHR work; proof techniques feed into GHR 1994 | Oxford Academic paywall |
| Reynolds 1994 — "Axiomatizing U and S over integer time" (ICTL 1994, LNCS 827) | MEDIUM — discrete-time specific | Springer paywall |
| Reynolds 1996 — "Axiomatising first-order temporal logic: Until and since over linear time" (Studia Logica 57:279–302) | MEDIUM — first-order extension | Springer paywall |

### 3. Missing Domain: Bimodal Combination Literature (Teammates B, C, D, HIGH confidence)

BX is a bimodal combination of S5 with linear tense logic, but the collection has zero sources from this tradition:

| Source | Relevance | Free PDF? |
|--------|-----------|-----------|
| Thomason 1984 — "Combinations of Tense and Modality" (HPL Vol. II, pp. 135–165) | **HIGH** — standard reference for modal-temporal combinations; same volume as Burgess 1984 | Same Springer paywall as Burgess 1984 |
| Caleiro, Viganò & Volpe 2013 — "On the Mosaic Method... combining tense and modal operators" (Logica Universalis 7(1)) | **HIGH** — proves completeness for *exactly* the S5 + linear tense structure of BX | Springer paywall |
| Finger & Gabbay 1992 — "Adding a temporal dimension to a logic system" (JLLI 1:203–233) | HIGH — "temporalization" framework showing completeness transfers for T(L) combinations | Springer paywall |

### 4. Missing Domain: Machine-Checked Formalization Literature (Teammates B, C, D, HIGH confidence)

The project is a Lean 4 formalization but cites zero prior formalizations:

| Source | Relevance | Free PDF? |
|--------|-----------|-----------|
| Obendrauf et al. 2024 — "Lean Formalization of Completeness Proof for Coalition Logic" (ITP 2024, LIPIcs 309) | **HIGH** — ~6,000 lines Lean 4 canonical model completeness; directly transferable patterns | **YES** — Dagstuhl DROPS open access |
| FormalizedFormalLogic/Foundation (GitHub) | HIGH — active Lean 4 project with S5 completeness via Henkin canonical models | **YES** — open source |
| LeanLTL 2025 — "A Unifying Framework for Linear Temporal Logics in Lean" (ITP 2025) | MEDIUM — LTL framework, trace-based not axiomatic | **YES** — arXiv 2507.01780 |

### 5. Quality Issue: Hodkinson-Reynolds 2006 Truncation Confirmed (Teammate C, HIGH confidence)

The PDF at `cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf` is byte-identical (51,937 bytes) to the file already in `literature/`. Text extraction confirms only the ToC and Introduction are present — no axiom systems, no completeness proofs, no filtration discussion. The critical Section 5 ("Temporal reasoning," pp. 696–712) is entirely inaccessible. No free full version exists anywhere. University library or ILL is the only route.

### 6. Hirsch-Hodkinson 1997 Should Be Deprioritized (Teammates C, D, MEDIUM-HIGH confidence)

The PostScript file at `doc.ic.ac.uk/~imh/papers/cylindric5.ps.gz` is still accessible (verified, 580KB). However, the paper addresses cylindric algebra representations — several levels of abstraction removed from BX's chain construction. Verbrugge 2004 (already obtained) provides the directly applicable step-by-step technique. Priority should be downgraded from MEDIUM to LOW.

### 7. Contextualization Sources for Publication (Teammate D, HIGH confidence)

Two additional sources would strengthen a publication introduction:

| Source | Relevance | Access |
|--------|-----------|--------|
| Segerberg 1970 — "Modal logics with linear alternative relations" (Theoria 36(3):301–322) | Foundation for the canonical model technique that Burgess 1982 extends | JSTOR |
| Blackburn, de Rijke, Venema 2001 — *Modal Logic* (Cambridge) | Standard modern textbook; Ch. 4 (completeness) and Ch. 7 (multi-modal systems) | ~$45 paperback |

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Goldblatt 1992 priority: A rates MEDIUM (filtration ruled out) vs. 04_literature-sources rated MEDIUM | Confirmed MEDIUM — filtration path is explicitly excluded by ROADMAP; add to "Not Yet Obtained" but don't prioritize acquisition |
| Hirsch-Hodkinson 1997 priority: README says MEDIUM vs. C says LOW | Downgrade to LOW — Verbrugge 2004 is the directly applicable step-by-step source; algebraic content is too distant |
| Scope of second wave: D says focus on 3–5 papers vs. B identifies 12 | Prioritize: add all with free PDFs now; track paywalled sources for future acquisition. Implementation task should focus on sources with accessible PDFs |

### Gaps Identified

1. **ILLC dissertations** (D) — Verbrugge's 2004 Festschrift paper omits proof details; ILLC dissertations from the 1990s may contain fuller step-by-step constructions. Worth a 1–2 hour search at `illc.uva.nl/Research/Publications/Dissertations/`
2. **Isabelle AFP entries** — no search conducted for modal/temporal logic entries in the Isabelle Archive of Formal Proofs
3. **Lean Zulip** — no search conducted for prior informal Lean 4 temporal logic formalization attempts

### Recommendations

**For the 'Second Research Wave' section in literature/README.md:**

**Tier 1 — Add immediately (free PDFs available):**
1. Burgess 1982b — "Axioms for tense logic. II. Time periods" (Project Euclid free PDF)
2. Venema 1993 — "Since and Until" (author preprint)
3. Obendrauf et al. 2024 — ITP Lean 4 Coalition Logic completeness (Dagstuhl DROPS)
4. FormalizedFormalLogic/Foundation — GitHub Lean 4 modal logic project

**Tier 2 — Track for acquisition (paywalled but important):**
5. Goldblatt 1992 — "Logics of Time and Computation" ($21 electronic)
6. Thomason 1984 — "Combinations of Tense and Modality" (same paywall as Burgess 1984)
7. Reynolds 1992 — IRR-free strict U,S completeness (Springer)
8. Caleiro et al. 2013 — S5 + tense mosaic method (Springer)
9. Finger & Gabbay 1992 — temporalization framework (Springer)
10. Gabbay & Hodkinson 1990 — U,S over reals (Oxford Academic)
11. Segerberg 1970 — canonical model technique foundation (JSTOR)

**Tier 3 — Lower priority:**
12. Reynolds 1994 — U,S over integers (LNCS, Springer)
13. Reynolds 1996 — first-order U,S (Springer)
14. LeanLTL 2025 — Lean LTL framework (arXiv)
15. Blackburn-de Rijke-Venema 2001 — Modal Logic textbook (~$45)

**Publication-critical action**: Obtain Xu 1988 (already tracked, not yet acquired). This is the single most important acquisition — the "X" in "BX."

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Primary | completed | Confirmed exactly 2 gaps between task 107 reports and README; verified Burgess 1982b free PDF on Project Euclid; downgraded Goldblatt relevance | high |
| B | Alternatives | completed | Discovered 12 new sources across 3 tiers; identified Reynolds/Venema strict-time cluster; found Lean 4 formalization projects | high |
| C | Critic | completed | Confirmed H-R 2006 truncation (byte-level); identified 3 missing domains; deprioritized Hirsch-Hodkinson 1997; flagged Thomason 1984 gap | high |
| D | Horizons | completed | Publication-blocking Xu 1988 gap; 3-question framework for publication readiness; ILLC dissertation suggestion; scoping recommendation | high |

## References

### New Sources Identified (not in current literature/README.md)

**Free PDF available:**
- Burgess, J. P. (1982). "Axioms for tense logic. II. Time periods." *NDJFL* 23(4), 375–383. DOI: [10.1305/ndjfl/1093870150](https://doi.org/10.1305/ndjfl/1093870150). PDF: [Project Euclid](https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-II-Time-periods/10.1305/ndjfl/1093870150.pdf)
- Venema, Y. (1993). "Since and Until." In *Diamonds and Defaults*, Synthese Library 229, Springer. Preprint: [staff.fnwi.uva.nl](https://staff.fnwi.uva.nl/y.venema/papers/vene-comp93.pdf)
- Obendrauf, K. et al. (2024). "Lean Formalization of Completeness Proof for Coalition Logic." *ITP 2024*, LIPIcs 309. [Dagstuhl DROPS](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28)
- FormalizedFormalLogic/Foundation. Lean 4 modal logic project. [GitHub](https://github.com/FormalizedFormalLogic/Foundation)

**Paywalled / to acquire:**
- Goldblatt, R. (1992). *Logics of Time and Computation* (2nd ed.). CSLI Publications. ISBN 978-0-937073-94-0.
- Thomason, R. H. (1984). "Combinations of Tense and Modality." In *HPL* Vol. II, pp. 135–165.
- Reynolds, M. (1992). "An axiomatization for until and since over the reals without the IRR rule." *Studia Logica* 51, 165–194.
- Caleiro, C., Viganò, L. & Volpe, M. (2013). "On the Mosaic Method..." *Logica Universalis* 7(1).
- Finger, M. & Gabbay, D. M. (1992). "Adding a temporal dimension to a logic system." *JLLI* 1, 203–233.
- Gabbay, D. M. & Hodkinson, I. M. (1990). "An axiomatization of the temporal logic with Until and Since over the real numbers." *JLC* 1(2), 229–260.
- Segerberg, K. (1970). "Modal logics with linear alternative relations." *Theoria* 36(3), 301–322.

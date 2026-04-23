# Literature Sources for Chain Construction Completeness Proof

**Task**: 107 - chain_design_diagnostics_for_representation_theorem
**Date**: 2026-04-23
**Effort**: Literature search
**Session**: sess_1776978557_19c61d
**Sources/Inputs**: Web search across academic databases
**Artifacts**: This report
**Standards**: N/A

---

## Executive Summary

Eight academic sources were identified across prior research rounds as relevant to the F-propagation problem in the BX chain construction. All eight have been located with citation details. Three have freely accessible PDFs confirmed downloaded. Two more have free access through institutional repositories. Three require journal/publisher subscription access.

The most immediately relevant paper is **Verbrugge et al.** (free PDF), which describes the exact "completeness by construction" technique for tense logics of linear time — directly applicable to the BX chain construction problem.

---

## Paper 1: Burgess 1982 — "Axioms for tense logic. I. 'Since' and 'until'"

| Field | Value |
|-------|-------|
| **Authors** | John P. Burgess |
| **Title** | Axioms for tense logic. I. "Since" and "until" |
| **Journal** | Notre Dame Journal of Formal Logic |
| **Volume/Issue** | 23(4) |
| **Pages** | 367–374 |
| **Year** | October 1982 |
| **DOI** | [10.1305/ndjfl/1093870149](https://doi.org/10.1305/ndjfl/1093870149) |
| **Project Euclid** | https://projecteuclid.org/euclid.ndjfl/1093870149 |
| **Free PDF** | **YES** — https://projecteuclid.org/journals/notre-dame-journal-of-formal-logic/volume-23/issue-4/Axioms-for-tense-logic-I-Since-and-until/10.1305/ndjfl/1093870149.pdf |
| **ResearchGate** | https://www.researchgate.net/publication/38355634 |

**Relevance**: This is the ORIGINAL axiomatization of Since/Until tense logic (the BX system). Presents axiomatizations for arbitrary, dense, and discrete linear orders. Contains the original completeness proof technique that the project's chain construction is attempting to formalize. **This is the single most important paper to study** — it shows how Burgess handles the F-resolution problem on linear chains.

**Note**: Prior research reports cited "Burgess 1984" — this is a conflation of two works. The Since/Until paper is from 1982. The 1984 reference is the handbook chapter (see Paper 1b below).

**Companion paper**: "Axioms for tense logic. II. Time periods" — same journal, same issue, pp. 375–383. DOI: [10.1305/ndjfl/1093870150](https://doi.org/10.1305/ndjfl/1093870150).

---

## Paper 1b: Burgess 1984 — "Basic Tense Logic" (Handbook Chapter)

| Field | Value |
|-------|-------|
| **Authors** | John P. Burgess |
| **Title** | Basic Tense Logic |
| **Book** | Handbook of Philosophical Logic, Vol. II: Extensions of Classical Logic |
| **Editors** | D. Gabbay, F. Guenthner |
| **Publisher** | D. Reidel (Synthese Library, vol. 165) |
| **Pages** | 89–133 |
| **Year** | 1984 |
| **Springer** | https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2 |
| **2nd Edition (2002)** | https://link.springer.com/chapter/10.1007/978-94-017-0462-5_1 |
| **Free PDF** | **NO** — requires Springer subscription |

**Relevance**: Comprehensive handbook survey of tense logic including completeness proofs. The 2nd edition (2002) may contain updated completeness techniques. Contains the textbook treatment of canonical model constructions for tense logics on various frame classes.

---

## Paper 2: Xu 1988 — "On some U,S-tense logics"

| Field | Value |
|-------|-------|
| **Authors** | Ming Xu |
| **Title** | On some U,S-tense logics |
| **Journal** | Journal of Philosophical Logic |
| **Volume/Issue** | 17(2) |
| **Pages** | 181–202 |
| **Year** | 1988 |
| **DOI** | [10.1007/BF00247911](https://doi.org/10.1007/BF00247911) |
| **PhilPapers** | https://philpapers.org/rec/XUOSU |
| **Springer** | https://link.springer.com/article/10.1007/BF00247911 |
| **JSTOR** | Available via JSTOR |
| **Free PDF** | **NO** — requires Springer/JSTOR subscription |

**Relevance**: Extends Burgess's axiomatization to bimodal settings combining temporal and modal operators — directly relevant to TM (Tense and Modality). The BX axiom system in this project is based on Burgess-Xu. Understanding Xu's completeness proof technique for the bimodal case would directly inform how to handle the S5 modal component alongside the temporal chain construction.

---

## Paper 3: Verbrugge et al. — "Completeness by construction for tense logics of linear time"

| Field | Value |
|-------|-------|
| **Authors** | Dick de Jongh, Frank Veltman, Rineke Verbrugge |
| **Title** | Completeness by construction for tense logics of linear time |
| **Book** | Vriendenboek ofwel Liber Amicorum ter gelegenheid van het afscheid van Dick de Jongh (Festschrift for Dick de Jongh) |
| **Publisher** | Institute for Logic, Language and Computation, University of Amsterdam |
| **Year** | 2004 (based on mid-1980s manuscript) |
| **Free PDF** | **YES** — https://festschriften.illc.uva.nl/D65/verbrugge.pdf |
| **ResearchGate** | https://www.researchgate.net/publication/252750536 |
| **DARE UvA** | https://dare.uva.nl/search?identifier=82b76c92-63f6-4471-9b12-938a03519f80 |

**Relevance**: **HIGHEST PRIORITY**. Describes the "constructive" method for tense logic completeness on linear discrete structures (consecutive copies of Z). The key technique: instead of building an infinite chain and proving global coherence, witnesses are INSERTED into a growing linear order stage by stage. This is exactly the de Jongh-Veltman-Verbrugge (dJVV) approach recommended by Teammate D as the most promising creative approach. The paper originated when Verbrugge was an undergraduate student of de Jongh and Veltman in the mid-1980s.

---

## Paper 4: Gabbay, Hodkinson & Reynolds 1994 — *Temporal Logic: Mathematical Foundations*

| Field | Value |
|-------|-------|
| **Authors** | Dov M. Gabbay, Ian Hodkinson, Mark Reynolds |
| **Title** | Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1 |
| **Publisher** | Oxford University Press (Clarendon Press) |
| **Series** | Oxford Logic Guides |
| **ISBN** | 978-0-19-853769-4 |
| **Year** | 1994 |
| **Pages** | 668 pp. |
| **OUP** | https://global.oup.com/academic/product/temporal-logic-9780198537694 |
| **Oxford Academic** | https://academic.oup.com/book/53043 |
| **Amazon** | https://www.amazon.com/dp/0198537697 |
| **Free PDF** | **NO** — book, requires purchase (~$200+ used) |

**Relevance**: The definitive reference monograph on temporal logic. Contains full completeness proofs for temporal logics with Since and Until on various frame classes (linear, dense, discrete, branching). Chapter coverage includes canonical model constructions, filtration, and the specific chain construction techniques used for Until/Since. **The relevant chapters are those on completeness for linear-time temporal logics with binary temporal operators.** This is the textbook treatment of the Burgess technique.

---

## Paper 5: Hirsch & Hodkinson 1997 — "Step by step — building representations in algebraic logic"

| Field | Value |
|-------|-------|
| **Authors** | Robin Hirsch, Ian Hodkinson |
| **Title** | Step by step — building representations in algebraic logic |
| **Journal** | Journal of Symbolic Logic |
| **Volume/Issue** | 62(1) |
| **Pages** | 225–279 |
| **Year** | March 1997 |
| **DOI** | [10.2307/2275740](https://doi.org/10.2307/2275740) |
| **Cambridge Core** | https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/abs/step-by-step-building-representations-in-algebraic-logic/2D6C50D1CCDAB0CD9B2F72543662739B |
| **Project Euclid** | https://projecteuclid.org/euclid.jsl/1183745193 |
| **Author PostScript** | http://www.doc.ic.ac.uk/~imh/papers/cylindric5.ps.gz (may require conversion) |
| **Free PDF** | **PARTIAL** — PostScript file from author's page; journal version requires subscription |

**Relevance**: Introduces the game-theoretic "step by step" method for building representations in algebraic logic. Uses model-theoretic finite forcing where one player proposes extensions and another challenges with defects. The framework naturally handles the "all defects eventually resolved" requirement. Teammate D identified this as a potential approach (Path 3) but estimated low-medium confidence due to the infrastructure overhead.

---

## Paper 6: Hodkinson & Reynolds 2006 — "Temporal Logic" (Handbook Chapter)

| Field | Value |
|-------|-------|
| **Authors** | Ian Hodkinson, Mark Reynolds |
| **Title** | Temporal Logic (Chapter 11) |
| **Book** | Handbook of Modal Logic |
| **Editors** | Patrick Blackburn, Johan van Benthem, Frank Wolter |
| **Publisher** | Elsevier Science |
| **Pages** | 655–720 |
| **Year** | 2006 |
| **Free PDF** | **YES** — https://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf |
| **Author's page** | https://www.doc.ic.ac.uk/~imh/frames_website/TL.html |

**Relevance**: Comprehensive survey of temporal logic including completeness theorems, axiomatizations, and decidability. Covers temporal logic with Since and Until, including the Burgess-Xu axiom system. Likely contains a modern treatment of the completeness proof technique with references to the specific chain construction method. Good starting point for a literature review before diving into the primary sources.

---

## Paper 7: Goldblatt 1992 — *Logics of Time and Computation* (2nd ed.)

| Field | Value |
|-------|-------|
| **Authors** | Robert Goldblatt |
| **Title** | Logics of Time and Computation (2nd edition, revised and expanded) |
| **Publisher** | CSLI Publications (Center for the Study of Language and Information, Stanford) |
| **Series** | CSLI Lecture Notes, No. 7 |
| **ISBN** | 978-0-937073-94-0 |
| **Year** | 1992 (2nd ed.; 1st ed. 1987) |
| **Pages** | ix + 180 pp. |
| **CSLI** | https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml |
| **Chicago Press** | https://press.uchicago.edu/ucp/books/book/distributed/L/bo3615704.html |
| **Free PDF** | **POSSIBLY** — reported at https://freecomputerbooks.com/Logics-of-Time-and-Computation.html (third-party site, verify legitimacy) |
| **Electronic** | Available for purchase ($21) from CSLI |

**Relevance**: Covers temporal logic of henceforth, next, and until; propositional dynamic logic; and computation tree logic (CTL). Chapter on tense logic completeness discusses canonical frame construction with filtration technique. Goldblatt's treatment of the linear frame construction and the key trick of unravelling the canonical model along a maximal chain is directly relevant.

---

## Paper 8: Reynolds 2001 — "An Axiomatization of Full Computation Tree Logic"

| Field | Value |
|-------|-------|
| **Authors** | Mark Reynolds |
| **Title** | An axiomatization of full computation tree logic |
| **Journal** | Journal of Symbolic Logic |
| **Volume/Issue** | 66(3) |
| **Pages** | 1011–1057 |
| **Year** | September 2001 (NOT 2003 as previously cited) |
| **DOI** | [10.2307/2695091](https://doi.org/10.2307/2695091) |
| **Cambridge Core PDF** | https://www.cambridge.org/core/services/aop-cambridge-core/content/view/D6FA9FAB6390F6C6ACCF7A831DF3CDE1/S0022481200010471a.pdf/an-axiomatization-of-full-computation-tree-logic.pdf |
| **Semantic Scholar** | https://www.semanticscholar.org/paper/9e083657c5ec0a2de0ef441538f3eb9d62bc5f99 |
| **Murdoch Repository** | https://researchportal.murdoch.edu.au/esploro/fulltext/journalArticle/An-axiomatization-of-full-computation-tree/991005544858807891 |
| **Free PDF** | **YES** — Cambridge Core open access PDF link above; also Murdoch institutional repository |

**Relevance**: Axiomatizes CTL* (branching time temporal logic). While TM uses linear time (not branching), Reynolds's rule-based canonical model technique and maximal consistent rule-sets may provide alternative approaches. The "tree unravelling" method is different from the linear chain approach but may offer structural insights. Lower priority than the linear-time sources.

---

## Summary: Access Status

| # | Paper | Free PDF? | Priority for F-Propagation Problem |
|---|-------|-----------|-------------------------------------|
| 3 | Verbrugge et al. (dJVV) | **YES** — ILLC Festschrift | **HIGHEST** — exact technique needed |
| 1 | Burgess 1982 | **YES** — Project Euclid | **HIGHEST** — original proof |
| 6 | Hodkinson & Reynolds 2006 | **YES** — Liverpool mirror | **HIGH** — survey with modern treatment |
| 8 | Reynolds 2001 | **YES** — Cambridge Core | MEDIUM — branching time, not linear |
| 5 | Hirsch & Hodkinson 1997 | **PARTIAL** — PS from author | MEDIUM — game-theoretic approach |
| 7 | Goldblatt 1992 | **POSSIBLY** — third-party | MEDIUM — canonical model + filtration |
| 2 | Xu 1988 | **NO** — Springer paywall | **HIGH** — bimodal extension of Burgess |
| 1b | Burgess 1984 | **NO** — Springer paywall | HIGH — textbook treatment |
| 4 | GHR 1994 | **NO** — OUP book (~$200) | HIGH — definitive reference |

## Recommended Reading Order

1. **Verbrugge et al.** (free PDF) — the constructive insertion technique directly applicable to BX
2. **Burgess 1982** (free PDF) — the original Since/Until axiomatization and completeness proof
3. **Hodkinson & Reynolds 2006** (free PDF) — modern survey for context and overview
4. **Xu 1988** (paywall) — bimodal extension; try institutional access or interlibrary loan
5. **GHR 1994** (book) — comprehensive treatment; check university library
6. Remaining papers as needed based on which approach is pursued

## Citation Corrections

The prior research reports contained two citation errors:
- "Burgess 1984" should be split: the Since/Until paper is **Burgess 1982** (NDJFL); the handbook chapter is **Burgess 1984** (HPL)
- "Reynolds 2003" is actually **Reynolds 2001** (JSL 66(3))

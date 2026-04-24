# Literature

Reference papers for the BX completeness proof, specifically the chain construction and F-propagation problem (task 107).

## Contents

### Available (PDF + Markdown)

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Burgess_1982_Axioms_for_tense_logic_Since_and_Until` | Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." *NDJFL* 23(4), 367--374. DOI: [10.1305/ndjfl/1093870149](https://doi.org/10.1305/ndjfl/1093870149) | **HIGHEST** -- original BX axiomatization and completeness proof for Since/Until on linear orders. Shows how Burgess handles F-resolution using maximal consistent sets. | Good (manually corrected OCR) |
| `Verbrugge_2004_Completeness_by_construction` | de Jongh, D., Veltman, F., Verbrugge, R. (2004). "Completeness by construction for tense logics of linear time." In *Liber Amicorum for Dick de Jongh*, ILLC Amsterdam. | **HIGHEST** -- the constructive "step-by-step" method for tense logic completeness. Builds models by inserting witnesses into a growing linear order rather than extending a fixed chain. Directly applicable to the BX F-propagation problem. | Good (clean extraction) |
| `Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11` | Hodkinson, I. & Reynolds, M. (2006). "Temporal Logic." Ch. 11 (pp. 655--720) in *Handbook of Modal Logic*, Elsevier. | **HIGH** -- modern survey covering axiomatizations, completeness, filtration, and the finite model property for temporal logics. | **Truncated**: only ToC + Introduction (3 pages of 66). Full chapter behind Elsevier paywall. |
| `Reynolds_2001_Axiomatization_Full_CTL_star` | Reynolds, M. (2001). "An axiomatization of full computation tree logic." *JSL* 66(3), 1011--1057. DOI: [10.2307/2695091](https://doi.org/10.2307/2695091) | MEDIUM -- branching time (CTL\*), not linear. Rule-based canonical model technique may offer structural insights. | Raw OCR with math artifacts; readable but notation is garbled in places. |

### Not Yet Obtained (require subscription/purchase)

| Citation | Relevance | Access |
|----------|-----------|--------|
| Xu, M. (1988). "On some U,S-tense logics." *JPL* 17(2), 181--202. DOI: [10.1007/BF00247911](https://doi.org/10.1007/BF00247911) | **HIGH** -- extends Burgess to bimodal (temporal + modal), directly relevant to TM. | Springer paywall |
| Burgess, J. P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic*, Vol. II, pp. 89--133. Reidel. | HIGH -- textbook treatment of tense logic completeness. | Springer paywall |
| Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1. OUP. ISBN 978-0-19-853769-4. | HIGH -- definitive reference monograph with full completeness proofs for Since/Until. | OUP book (~$200) |
| Hirsch, R. & Hodkinson, I. (1997). "Step by step -- building representations in algebraic logic." *JSL* 62(1), 225--279. DOI: [10.2307/2275740](https://doi.org/10.2307/2275740) | MEDIUM -- game-theoretic model construction; PostScript from author's page at `doc.ic.ac.uk/~imh/papers/cylindric5.ps.gz` | Cambridge Core paywall; author PS available |

## Recommended Reading Order

1. **Verbrugge 2004** -- the constructive insertion technique, directly applicable
2. **Burgess 1982** -- the original Since/Until axiomatization and completeness proof
3. **Xu 1988** -- bimodal extension (obtain via institutional access)
4. **GHR 1994** -- comprehensive treatment (check university library)

## Citation Corrections

Prior research reports contained two errors:
- "Burgess 1984" for the Since/Until paper should be **Burgess 1982** (NDJFL). The 1984 reference is the separate handbook chapter "Basic Tense Logic."
- "Reynolds 2003" should be **Reynolds 2001** (JSL 66(3)).

## Second Research Wave

Sources identified during task 107 chain construction research and the subsequent task 111 gap analysis. Organized by availability and domain. These expand the collection from the original Burgess/Verbrugge core to cover strict-time extensions, bimodal combination theory, and machine-checked formalizations.

> **Publication-critical**: Xu 1988 ("On some U,S-tense logics") defines the axiom system formalized in this project (the "X" in "BX"). It is tracked in the first wave above but has **not yet been obtained**. This must be acquired before any publication submission.

### Obtained (PDF in literature/)

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Burgess_1982b_Axioms_for_tense_logic_II_Time_periods` | Burgess, J. P. (1982). "Axioms for tense logic. II. Time periods." *NDJFL* 23(4), 375--383. DOI: [10.1305/ndjfl/1093870150](https://doi.org/10.1305/ndjfl/1093870150) | **HIGH** -- companion to Part I; extends Since/Until axiomatization to time-period operators. Cited in task 107 round 7 chain construction work. | Good (Project Euclid scan, 798KB) |
| `Venema_1993_Since_and_Until` | Venema, Y. (1993). "Since and Until." In *Diamonds and Defaults*, Synthese Library 229, Springer. | **HIGHEST** -- extends Burgess/Xu to strict and discrete time. "Completeness via Completeness" explains three intertwined senses of completeness for U,S logics. Directly relevant to BX's irreflexive temporal ordering. | Good (author preprint, 130KB) |
| `Obendrauf_2024_Lean_Formalization_Coalition_Logic` | Obendrauf, K., Baanen, A., Koopmann, P. & Stebletsova, V. (2024). "Lean Formalization of Completeness Proof for Coalition Logic with Common Knowledge." *ITP 2024*, LIPIcs 309, pp. 28:1--28:18. DOI: [10.4230/LIPIcs.ITP.2024.28](https://doi.org/10.4230/LIPIcs.ITP.2024.28) | **HIGH** -- ~6,000 lines Lean 4 canonical model completeness proof; directly transferable patterns for type class generalization and Lindenbaum construction. | Good (Dagstuhl DROPS open access, 849KB) |
| *(GitHub repository)* | FormalizedFormalLogic/Foundation. Lean 4 modal logic project. [GitHub](https://github.com/FormalizedFormalLogic/Foundation) | HIGH -- active Lean 4 project with S5 completeness via Henkin canonical models. Structural patterns directly applicable to BX formalization. | Open source; ongoing development |

### Strict-Time Since/Until Extensions (Not Yet Obtained)

Sources extending the Burgess 1982 framework to strict (irreflexive) and discrete temporal orderings -- directly relevant to BX's use of strict temporal operators.

| Citation | Relevance | Access |
|----------|-----------|--------|
| Reynolds, M. (1992). "An axiomatization for until and since over the reals without the IRR rule." *Studia Logica* 51, 165--194. | **HIGH** -- canonical reference for IRR-free strict U,S completeness. Directly relevant to BX chain construction. | Springer paywall |
| Gabbay, D. M. & Hodkinson, I. M. (1990). "An axiomatization of the temporal logic with Until and Since over the real numbers." *JLC* 1(2), 229--260. | HIGH -- foundational work; proof techniques feed into GHR 1994 monograph. | Oxford Academic paywall |
| Reynolds, M. (1994). "Axiomatising U and S over integer time." *ICTL 1994*, LNCS 827. | MEDIUM -- discrete-time specific axiomatization. | Springer paywall |
| Reynolds, M. (1996). "Axiomatising first-order temporal logic: Until and since over linear time." *Studia Logica* 57, 279--302. | MEDIUM -- first-order extension of U,S framework. | Springer paywall |

Note: Venema 1993 (covering strict/discrete time) is listed under "Obtained" above.

### Bimodal Combination Literature (Not Yet Obtained)

BX is a bimodal combination of S5 with linear tense logic. These sources address the theory of combining modal logics, which the current collection entirely lacks.

| Citation | Relevance | Access |
|----------|-----------|--------|
| Thomason, R. H. (1984). "Combinations of Tense and Modality." In *Handbook of Philosophical Logic*, Vol. II, pp. 135--165. Reidel. | **HIGH** -- standard reference for modal-temporal combinations; same volume as Burgess 1984. | Springer paywall (same as Burgess 1984) |
| Caleiro, C., Viganò, L. & Volpe, M. (2013). "On the Mosaic Method for Many-Dimensional Modal Logics." *Logica Universalis* 7(1). | **HIGH** -- proves completeness for exactly the S5 + linear tense structure of BX using mosaic methods. | Springer paywall |
| Finger, M. & Gabbay, D. M. (1992). "Adding a temporal dimension to a logic system." *JLLI* 1, 203--233. | HIGH -- "temporalization" framework showing completeness transfers for T(L) combinations. | Springer paywall |

### Machine-Checked Formalizations

| Citation | Relevance | Access |
|----------|-----------|--------|
| Obendrauf et al. 2024 | See "Obtained" above -- Lean 4 coalition logic completeness. | PDF in `literature/` |
| FormalizedFormalLogic/Foundation | See "Obtained" above -- Lean 4 S5 completeness. | [GitHub](https://github.com/FormalizedFormalLogic/Foundation) |
| Zhan, B. et al. (2025). "A Unifying Framework for Linear Temporal Logics in Lean." *ITP 2025*. arXiv: [2507.01780](https://arxiv.org/abs/2507.01780) | MEDIUM -- LTL framework in Lean 4; trace-based rather than axiomatic, but Lean 4 patterns may transfer. | arXiv preprint (free) |

### General References (Not Yet Obtained)

| Citation | Relevance | Access |
|----------|-----------|--------|
| Goldblatt, R. (1992). *Logics of Time and Computation* (2nd ed.). CSLI Publications. ISBN 978-0-937073-94-0. | MEDIUM -- uses filtration technique (ruled out for BX representation theorem, but useful background). | $21 electronic from CSLI |
| Segerberg, K. (1970). "Modal logics with linear alternative relations." *Theoria* 36(3), 301--322. | MEDIUM -- foundation for the canonical model technique that Burgess 1982 extends. | JSTOR |
| Blackburn, P., de Rijke, M. & Venema, Y. (2001). *Modal Logic*. Cambridge University Press. | MEDIUM -- standard modern textbook; Ch. 4 (completeness) and Ch. 7 (multi-modal systems) provide context. | ~$45 paperback |

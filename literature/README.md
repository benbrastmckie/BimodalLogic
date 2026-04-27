# Literature

Reference papers for the BX completeness proof. Organized by topic; all obtained papers have both PDF and Markdown conversions in this directory.

## Recent Additions

Three papers newly obtained and converted. Each addresses a gap in the collection:

| Paper | What it adds | Where to start |
|-------|-------------|----------------|
| **Xu 1988** | The "X" in BX. Extends Burgess's U,S completeness methods from linear to non-linear (branching) time. Sections 3--4 on expressibility show which first-order properties U,S can/cannot define -- irreflexivity is among those it *cannot*, which motivates the special handling in BX. | Section 2 (minimal U,S-tense logic) for the canonical model construction; Section 4 for the expressibility limits. |
| **Reynolds 1992** | IRR-free axiomatization of U,S over the reals. Shows how to get completeness for strict (irreflexive) temporal ordering *without* the non-orthodox IRR rule used by Gabbay--Hodkinson. Uses Doets's theorem (Doets 1989) to transfer from rational-flowed to real-flowed models. | Section 3 (comparison with IRR rule) for motivation; Sections 5--9 for the completeness proof architecture. |
| **Caleiro--Viganò--Volpe 2013** | Mosaic method for exactly the S5 + linear tense combination that BX uses. Proves completeness and decidability via finite sets of partial models ("mosaics") rather than canonical models. Also develops a tableau system. | Section 2 (the combined logic definition) to see how they set up S5 + tense; Section 4.1 (completeness via mosaics) for the alternative completeness route. |

## Recommended Reading Order

1. **Burgess 1982** -- the original Since/Until axiomatization and completeness proof
2. **Xu 1988** -- generalizes Burgess to non-linear time; defines the axiom system formalized in this project
3. **Verbrugge 2004** -- the constructive step-by-step insertion technique for model building
4. **Venema 1993** -- extends to strict and discrete time; "Completeness via Completeness"
5. **Reynolds 1992** -- IRR-free completeness over the reals; uses Doets's theorem
6. **Thomason 1984** -- standard reference for combining tense and modality
7. **Caleiro--Viganò--Volpe 2013** -- mosaic-based completeness for S5 + tense

---

## Obtained Papers

### Core BX Theory

The papers that define and extend the Burgess--Xu axiom system for Until/Since tense logics.

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Burgess_1982_Axioms_for_tense_logic_Since_and_Until` | Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." *NDJFL* 23(4), 367--374. DOI: [10.1305/ndjfl/1093870149](https://doi.org/10.1305/ndjfl/1093870149) | **HIGHEST** -- original BX axiomatization and completeness proof for Since/Until on linear orders. Shows how Burgess handles F-resolution using maximal consistent sets. | Good (manually corrected OCR) |
| `Burgess_1982b_Axioms_for_tense_logic_II_Time_periods` | Burgess, J. P. (1982). "Axioms for tense logic. II. Time periods." *NDJFL* 23(4), 375--383. DOI: [10.1305/ndjfl/1093870150](https://doi.org/10.1305/ndjfl/1093870150) | **HIGH** -- companion to Part I; extends Since/Until axiomatization to time-period operators. | Good (Project Euclid scan) |
| `Xu_1988_On_some_US_tense_logics` | Xu, M. (1988). "On some U,S-tense logics." *JPL* 17(2), 181--202. DOI: [10.1007/BF00247911](https://doi.org/10.1007/BF00247911) | **HIGHEST** -- the "X" in BX. Extends Burgess's completeness methods to non-linear (branching) time; establishes expressibility limits of U,S language (irreflexivity is not U,S-definable). | Good (Springer scan, OCR corrected) |
| `Burgess_1984_Basic_Tense_Logic` | Burgess, J. P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic*, Vol. II, pp. 89--133. Reidel. | HIGH -- textbook treatment of tense logic completeness; same volume as Thomason 1984. | OCR from scanned PDF; math symbols may need spot-checking. |

### Strict-Time Extensions

Papers addressing irreflexive temporal ordering -- directly relevant to BX's use of strict temporal operators.

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Venema_1993_Since_and_Until` | Venema, Y. (1993). "Since and Until." In *Diamonds and Defaults*, Synthese Library 229, Springer. | **HIGHEST** -- extends Burgess/Xu to strict and discrete time. "Completeness via Completeness" explains three intertwined senses of completeness for U,S logics. Directly relevant to BX's irreflexive temporal ordering. | Good (author preprint) |
| `Reynolds_1992_Axiomatization_Until_Since_without_IRR` | Reynolds, M. (1992). "An axiomatization for until and since over the reals without the IRR rule." *Studia Logica* 51, 165--193. | **HIGH** -- canonical reference for IRR-free strict U,S completeness. Proves completeness over the reals using orthodox inference rules only, via Doets's theorem to transfer from rational to real flows. Directly relevant to BX chain construction. | Good (Springer scan, OCR corrected) |
| `Doets_1989_Monadic_Pi11_Theories` | Doets, K. (1989). "Monadic Pi-1-1-Theories of Pi-1-1-Properties." *NDJFL* 30(2), 224--240. DOI: [10.1305/ndjfl/1093635080](https://doi.org/10.1305/ndjfl/1093635080) | **HIGH** -- Theorem 3.8 (definably well-ordered linear models have well-ordered n-equivalents) is the key technical lemma enabling Venema 1993's model-replacement technique and Reynolds 1992's rational-to-real transfer. | Good (Project Euclid, clean extraction) |

### Completeness Techniques

Model construction methods applicable to the BX representation theorem.

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Verbrugge_2004_Completeness_by_construction` | de Jongh, D., Veltman, F., Verbrugge, R. (2004). "Completeness by construction for tense logics of linear time." In *Liber Amicorum for Dick de Jongh*, ILLC Amsterdam. | **HIGHEST** -- constructive "step-by-step" method. Builds models by inserting witnesses into a growing linear order rather than extending a fixed chain. Directly applicable to the BX F-propagation problem. | Good (clean extraction) |
| `Reynolds_2001_Axiomatization_Full_CTL_star` | Reynolds, M. (2001). "An axiomatization of full computation tree logic." *JSL* 66(3), 1011--1057. DOI: [10.2307/2695091](https://doi.org/10.2307/2695091) | MEDIUM -- branching time (CTL\*), not linear. Rule-based canonical model technique may offer structural insights. | Raw OCR with math artifacts; readable but notation is garbled in places. |

### Bimodal Combination Theory

BX is a bimodal combination of S5 with linear tense logic. These papers address the theory of combining modal logics.

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Thomason_1984_Combinations_of_Tense_and_Modality` | Thomason, R. H. (1984). "Combinations of Tense and Modality." In *Handbook of Philosophical Logic*, Vol. II, pp. 135--165. Reidel. | **HIGH** -- standard reference for modal-temporal combinations; same volume as Burgess 1984. | OCR from scanned PDF; math symbols may need spot-checking. |
| `Caleiro_Vigano_Volpe_2013_Mosaic_Method_Tense_Modal` | Caleiro, C., Vigano, L. & Volpe, M. (2013). "On the Mosaic Method for Many-Dimensional Modal Logics." *Logica Universalis* 7(1), 33--69. DOI: [10.1007/s11787-012-0074-5](https://doi.org/10.1007/s11787-012-0074-5) | **HIGH** -- proves completeness and decidability for exactly the S5 + linear tense structure of BX using mosaic methods. Offers an alternative to canonical model completeness. Also develops a tableau system. | Good (Springer, clean extraction) |

### Machine-Checked Formalizations

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Obendrauf_2024_Lean_Formalization_Coalition_Logic` | Obendrauf, K., Baanen, A., Koopmann, P. & Stebletsova, V. (2024). "Lean Formalization of Completeness Proof for Coalition Logic with Common Knowledge." *ITP 2024*, LIPIcs 309, pp. 28:1--28:18. DOI: [10.4230/LIPIcs.ITP.2024.28](https://doi.org/10.4230/LIPIcs.ITP.2024.28) | **HIGH** -- ~6,000 lines Lean 4 canonical model completeness proof; directly transferable patterns for type class generalization and Lindenbaum construction. | Good (Dagstuhl DROPS open access) |
| *(GitHub repository)* | FormalizedFormalLogic/Foundation. Lean 4 modal logic project. [GitHub](https://github.com/FormalizedFormalLogic/Foundation) | HIGH -- active Lean 4 project with S5 completeness via Henkin canonical models. Structural patterns directly applicable to BX formalization. | Open source; ongoing development |

### Surveys

| File | Citation | Relevance | Quality |
|------|----------|-----------|---------|
| `Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11` | Hodkinson, I. & Reynolds, M. (2006). "Temporal Logic." Ch. 11 (pp. 655--720) in *Handbook of Modal Logic*, Elsevier. | **HIGH** -- modern survey covering axiomatizations, completeness, filtration, and the finite model property for temporal logics. | **Truncated**: only ToC + Introduction (3 of 66 pages). Full chapter requires Elsevier subscription or ILL. |

---

## Not Yet Obtained

### High Priority

| Citation | Relevance | Access |
|----------|-----------|--------|
| Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1. OUP. ISBN 978-0-19-853769-4. | HIGH -- definitive reference monograph with full completeness proofs for Since/Until. | OUP book (~$200) |
| Finger, M. & Gabbay, D. M. (1992). "Adding a temporal dimension to a logic system." *JLLI* 1, 203--233. | HIGH -- "temporalization" framework showing completeness transfers for T(L) combinations. | Springer paywall |
| Gabbay, D. M. & Hodkinson, I. M. (1990). "An axiomatization of the temporal logic with Until and Since over the real numbers." *JLC* 1(2), 229--260. | HIGH -- foundational work using the IRR rule; proof techniques feed into GHR 1994 monograph. Reynolds 1992 provides the IRR-free alternative. | Oxford Academic paywall |

### Medium Priority

| Citation | Relevance | Access |
|----------|-----------|--------|
| Reynolds, M. (1994). "Axiomatising U and S over integer time." *ICTL 1994*, LNCS 827. | MEDIUM -- discrete-time specific axiomatization. | Springer paywall |
| Reynolds, M. (1996). "Axiomatising first-order temporal logic: Until and since over linear time." *Studia Logica* 57, 279--302. | MEDIUM -- first-order extension of U,S framework. | Springer paywall |
| Zhan, B. et al. (2025). "A Unifying Framework for Linear Temporal Logics in Lean." *ITP 2025*. arXiv: [2507.01780](https://arxiv.org/abs/2507.01780) | MEDIUM -- LTL framework in Lean 4; trace-based rather than axiomatic, but Lean 4 patterns may transfer. | arXiv preprint (free) |
| Goldblatt, R. (1992). *Logics of Time and Computation* (2nd ed.). CSLI Publications. ISBN 978-0-937073-94-0. | MEDIUM -- uses filtration technique (ruled out for BX representation theorem, but useful background). | $21 electronic from CSLI |
| Segerberg, K. (1970). "Modal logics with linear alternative relations." *Theoria* 36(3), 301--322. | MEDIUM -- foundation for the canonical model technique that Burgess 1982 extends. | JSTOR |
| Blackburn, P., de Rijke, M. & Venema, Y. (2001). *Modal Logic*. Cambridge University Press. | MEDIUM -- standard modern textbook; Ch. 4 (completeness) and Ch. 7 (multi-modal systems) provide context. | ~$45 paperback |

### Low Priority

| Citation | Relevance | Access |
|----------|-----------|--------|
| Hirsch, R. & Hodkinson, I. (1997). "Step by step -- building representations in algebraic logic." *JSL* 62(1), 225--279. DOI: [10.2307/2275740](https://doi.org/10.2307/2275740) | LOW -- game-theoretic model construction for cylindric algebras; Verbrugge 2004 provides the directly applicable step-by-step technique. | Cambridge Core paywall |

---

## Citation Corrections

Prior research reports contained two errors:
- "Burgess 1984" for the Since/Until paper should be **Burgess 1982** (NDJFL). The 1984 reference is the separate handbook chapter "Basic Tense Logic."
- "Reynolds 2003" should be **Reynolds 2001** (JSL 66(3)).

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

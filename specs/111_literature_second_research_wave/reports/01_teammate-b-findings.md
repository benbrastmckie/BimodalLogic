# Teammate B Findings: Alternative Approaches Literature Search

**Task 111 — Literature Second Research Wave**
**Teammate Role**: Alternative Approaches
**Date**: 2026-04-24

---

## Key Findings

This report identifies papers NOT in the original 9-paper tracking list that are relevant to the BX completeness proof, organized by theme. The primary discovery is a rich cluster of Reynolds and Venema papers that directly extend Burgess/Xu and handle related proof problems, plus several Lean 4 formalization projects with canonical model techniques that could inform the mechanization effort.

---

## Recommended Sources to Add

### Tier 1: Directly Relevant to Since/Until Completeness

**R1. Reynolds 1992 — "An axiomatization for until and since over the reals without the IRR rule"**
- Full citation: Reynolds, M. (1992). An axiomatization for until and since over the reals without the IRR rule. *Studia Logica*, 51, 165–194.
- Relevance: Provides a complete axiomatization for Until/Since over the real numbers *without* the Irreflexivity Rule (IRR), a non-standard rule needed in earlier approaches. This is the paper typically cited alongside Burgess/Xu as foundational for strict-time U,S completeness. Directly relevant to the chain construction since the completeness proof avoids the IRR rule, suggesting alternative techniques for handling the irreflexivity requirement.
- Accessibility: Available via SpringerLink DOI 10.1007/BF00370112.

**R2. Reynolds 1994 — "Axiomatizing U and S over integer time"**
- Full citation: Reynolds, M. (1994). Axiomatizing U and S over integer time. In D. M. Gabbay & H. J. Ohlbach (Eds.), *Temporal Logic: First International Conference, ICTL 1994*, Lecture Notes in Computer Science, vol. 827, Springer, Berlin/Heidelberg.
- Relevance: Proves weak completeness for U,S over integer (discrete) time — directly in the lineage of Burgess/Xu for a specific time class. This is an important reference for how discrete-time U,S completeness is handled differently from the dense/all-linear-orders case.
- Accessibility: Available via SpringerLink DOI 10.1007/BFb0013984.

**R3. Reynolds 1996 — "Axiomatising first-order temporal logic: Until and since over linear time"**
- Full citation: Reynolds, M. (1996). Axiomatising first-order temporal logic: Until and since over linear time. *Studia Logica*, 57, 279–302.
- Relevance: Extends to first-order temporal logic with U,S over all linear flows of time, proving completeness of the axiom system. This is the first-order companion to the propositional Burgess/Xu result and explores how the chain-construction completeness proof scales to first-order. The techniques used to handle the first-order case often illuminate aspects of the propositional case.
- Accessibility: Available via SpringerLink DOI 10.1007/BF00370836.

**R4. Venema 1993 — "Since and Until" (Completeness via Completeness)**
- Full citation: Venema, Y. (1993). Since and Until. In M. de Rijke (Ed.), *Diamonds and Defaults*, Synthese Library, vol. 229, Springer, Dordrecht.
- Also accessible as a preprint: https://staff.fnwi.uva.nl/y.venema/papers/vene-comp93.pdf
- Relevance: This is the paper establishing that the Burgess/Xu axiomatization (translated to strict U,S) is complete for discrete linear orderings, well-orderings, and the naturals by adding specific axioms. The title "Since and Until" and the chapter "Completeness via Completeness" show the interconnection of three senses of completeness for U,S. This is the paper cited in the SEP Burgess-Xu supplement as extending to strict time. Directly relevant to understanding how the discrete-time case is handled, including what axioms are needed for the chain to "close off" properly.
- Accessibility: Preprint PDF available at staff.fnwi.uva.nl; Springer chapter DOI 10.1007/978-94-015-8242-1_12.

**R5. Gabbay & Hodkinson 1990 — "An axiomatization of the temporal logic with Until and Since over the real numbers"**
- Full citation: Gabbay, D. M. & Hodkinson, I. M. (1990). An axiomatization of the temporal logic with Until and Since over the real numbers. *Journal of Logic and Computation*, 1(2), 229–260.
- Relevance: The earlier foundational work by GHR book authors on completeness for U,S over the reals. The proof techniques here (Hilbert-style axiomatization, completeness with respect to single formulas, independence of axioms) directly feed into the book-length treatment in GHR 1994. Relevant as the source for the proof methodology adopted in Verbrugge et al. 2004.
- Accessibility: Available via Oxford Academic DOI 10.1093/logcom/1.2.229.

### Tier 2: Relevant Proof Techniques and Bimodal Combinations

**R6. Venema 1994 — "Completeness through flatness in two-dimensional temporal logic"**
- Full citation: Venema, Y. (1994). Completeness through flatness in two-dimensional temporal logic. In D. M. Gabbay & H. J. Ohlbach (Eds.), *Temporal Logic: First International Conference, ICTL 1994*, Lecture Notes in Computer Science, vol. 827, Springer.
- Relevance: Addresses completeness for *two-dimensional* temporal logic (combining two temporal dimensions), using a "flatness" technique. This is directly relevant to BX's bimodal structure (S5 + tense). The flatness technique is a way of handling the interaction between two modal dimensions in the canonical model construction — closely related to the F-propagation problem.
- Accessibility: Available via SpringerLink DOI 10.1007/BFb0013986.

**R7. Finger & Gabbay 1992 — "Adding a temporal dimension to a logic system"**
- Full citation: Finger, M. & Gabbay, D. M. (1992). Adding a temporal dimension to a logic system. *Journal of Logic, Language and Information*, 1, 203–233.
- Relevance: Introduces the methodology of "temporalizing" a logic L by combining it with a temporal logic T to create T(L), showing that soundness and completeness transfer from L and T to T(L). Since BX is essentially S5 temporalized with Since/Until tense logic, this is a key reference for the theoretical foundation of the completeness proof approach. The transfer-of-completeness result may directly justify the BX completeness structure.
- Accessibility: Available via SpringerLink DOI 10.1007/BF00156915.

**R8. Caleiro, Viganò & Volpe 2013 — "On the Mosaic Method for Many-Dimensional Modal Logics: A Case Study Combining Tense and Modal Operators"**
- Full citation: Caleiro, C., Viganò, L. & Volpe, M. (2013). On the mosaic method for many-dimensional modal logics: A case study combining tense and modal operators. *Logica Universalis*, 7(1).
- Relevance: Applies the mosaic method specifically to logics combining *linear tense operators* with an *orthogonal S5-like modality* — exactly the structure of BX. Proves decidability and Hilbert-style completeness via mosaics and also provides mosaic-based tableaux. This is the closest paper to BX's specific bimodal structure in the secondary literature.
- Accessibility: Available via SpringerLink DOI 10.1007/s11787-012-0074-5.

**R9. Kurucz 2006 — "Combining Modal Logics" (Handbook of Modal Logic, Chapter 15)**
- Full citation: Kurucz, Á. (2006). Combining modal logics. In P. Blackburn, J. van Benthem & F. Wolter (Eds.), *Handbook of Modal Logic*, Elsevier, pp. 869–924.
- Relevance: Comprehensive treatment of product logics and fusion logics, including products with S5. Covers completeness and decidability for S5 combined with other modal/tense logics. The chapter on "Products with S5" is particularly relevant since BX = S5 × (tense with U,S). Provides the theoretical framework for why the BX completeness proof has the structure it does.
- Accessibility: The handbook is widely available; the chapter is also at King's Research Portal.

### Tier 3: Lean 4 Formalization Techniques

**R10. Obendrauf, Baanen, Koopmann & Stebletsova 2024 — "Lean Formalization of Completeness Proof for Coalition Logic with Common Knowledge"**
- Full citation: Obendrauf, K., Baanen, A., Koopmann, P. & Stebletsova, V. (2024). Lean formalization of completeness proof for coalition logic with common knowledge. In *Proceedings of the 15th International Conference on Interactive Theorem Proving (ITP 2024)*, LIPIcs, vol. 309, Schloss Dagstuhl.
- Relevance: The most recent (2024) ITP paper formalizing a modal logic completeness proof in Lean 4, using the canonical coalition model built from maximal consistent sets. The project is ~6,000 lines and proves both soundness and completeness for CLC. The techniques (truth lemma, canonical model construction, maximal consistent set extension) are directly transferable to BX. Demonstrates the current state of the art for such formalizations.
- Accessibility: Open access at https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28.

**R11. FormalizedFormalLogic/Foundation (GitHub Project)**
- Full citation: FormalizedFormalLogic. Foundation: Formalization of Mathematical Logic. GitHub repository (active as of 2026). https://github.com/FormalizedFormalLogic/Foundation
- Documentation: https://formalizedformallogic.github.io/Book/
- Relevance: A comprehensive Lean 4 formalization project that includes soundness and completeness for modal logics K, KD, S4, and S5 using Henkin-style canonical model construction. The formalized results include maximal consistent theories, canonical Kripke frames, and the truth lemma. The S5 completeness proof here is directly analogous to what BX needs for its modal dimension, and the Lean 4 code patterns are directly applicable.
- Accessibility: Fully open source on GitHub.

**R12. LeanLTL 2025 — "A Unifying Framework for Linear Temporal Logics in Lean"**
- Full citation: (Authors listed in paper.) LeanLTL: A unifying framework for linear temporal logics in Lean. In *Proceedings of ITP 2025*, LIPIcs, vol. (forthcoming). Preprint: arXiv 2507.01780.
- Relevance: A 2025 ITP paper building a Lean 4 framework for LTL reasoning over traces (finite or infinite). While it focuses on trace-based LTL rather than axiomatic completeness, it demonstrates how linear temporal reasoning is being mechanized in Lean 4 using Mathlib. Useful for understanding the Lean idioms for temporal operators.
- Accessibility: arXiv preprint at https://arxiv.org/abs/2507.01780; also in LIPIcs ITP 2025.

---

## Evidence and Examples

### Reynolds 1992 (R1) — The IRR-Free Proof
The SEP Burgess-Xu supplement explicitly states: "Extensions of this axiomatization for strict linear orderings were obtained by Venema (1993) and Reynolds (1994; 1996)." The Reynolds 1992 Studia Logica paper provides an axiomatization for U,S over the reals that avoids the Irreflexivity Rule, a non-standard inference rule of the form "from (p ∧ H¬p) → φ, deduce φ (where p does not occur in φ)". This rule is "slightly controversial" per the literature because it is not a standard Hilbert rule. The BX proof almost certainly has to deal with this same issue — since the time ordering in BX is strict (irreflexive), and the canonical model construction needs irreflexivity, this Reynolds paper is essential background.

### Venema 1993 (R4) — The Three-Way Completeness Interplay
The abstract of the "Completeness via Completeness" chapter explicitly discusses how for the U,S formalism:
1. Dedekind-completeness of the flow of time
2. Expressive completeness of U,S over first-order logic
3. Axiomatic completeness of the axiomatization
are all *intertwined*. This is directly relevant to BX's proof structure, where the F-propagation challenge involves ensuring that "until" formulas are eventually realized in the canonical chain — which is exactly the connection between axiomatic completeness and the ordering properties of the model.

### Caleiro et al. 2013 (R8) — The Closest Bimodal Match
The abstract of this Logica Universalis paper states: "we present the mosaic method for logics arising from the combination of linear tense operators with an 'orthogonal' S5-like modality." This is exactly the BX structure. The paper proves: (a) decidability, (b) completeness of a Hilbert-style axiomatization, and (c) a mosaic-based tableau system. While the mosaic method differs from the canonical chain construction used in BX, the completeness result for this exact logic combination confirms the completeness claim being formalized and provides an alternative proof path that could be referenced.

### Finger & Gabbay 1992 (R7) — The Temporalization Framework
The abstract states that T(L) preserves "soundness, completeness, decidability, conservativeness and separation over linear flows of time" from the component logics. If BX fits the T(L) schema (i.e., it is S5 "temporalized" with Burgess/Xu tense logic), then this paper's transfer theorem provides a theoretical shortcut to the completeness proof — BX is complete because both S5 and the tense logic are complete, and the combination preserves completeness. This needs verification against BX's exact axiom system.

### FormalizedFormalLogic/Foundation (R11) — Lean 4 Patterns
The GitHub repository shows completed S5 completeness in Lean 4 using:
- Maximal consistent theories
- The Lindenbaum lemma
- Canonical Kripke frame construction
- The truth lemma

The BX proof's modal dimension (S5) is exactly the same, so the code patterns from this project are directly reusable for the S5 part of the BX canonical model.

---

## Confidence Level

**High confidence** (independently verified through multiple sources):
- R1 (Reynolds 1992, Studia Logica 51): confirmed via SpringerLink and SEP citation
- R4 (Venema 1993, "Since and Until"): confirmed via SEP supplement, Springer, and preprint URL
- R5 (Gabbay & Hodkinson 1990): confirmed via Semantic Scholar and Oxford Academic
- R7 (Finger & Gabbay 1992): confirmed via SpringerLink and ResearchGate
- R8 (Caleiro et al. 2013): confirmed via SpringerLink
- R9 (Kurucz 2006): confirmed via King's Research Portal and Elsevier
- R10 (Obendrauf et al. 2024): confirmed via Dagstuhl/LIPIcs open access
- R11 (FormalizedFormalLogic/Foundation): confirmed via GitHub and project book site

**Medium confidence** (found but less detail verified):
- R2 (Reynolds 1994, ICTL): found via DBLP and SpringerLink, full text not confirmed accessible without paywall
- R3 (Reynolds 1996, Studia Logica 57): confirmed via SpringerLink abstract
- R6 (Venema 1994, ICTL): found via SpringerLink, full text behind paywall
- R12 (LeanLTL 2025): confirmed via arXiv abstract; ITP 2025 proceedings still pending

---

## Summary Assessment

The most important new papers are:
1. **Reynolds 1992** (R1) — the canonical reference for IRR-free strict U,S completeness
2. **Venema 1993** (R4) — directly extends Burgess/Xu to strict/discrete time with chain construction insight
3. **Caleiro et al. 2013** (R8) — the only paper proving completeness for exactly the S5 + linear tense bimodal structure
4. **FormalizedFormalLogic/Foundation** (R11) — Lean 4 code for S5 completeness directly reusable

The Reynolds 1992 and Venema 1993 papers are particularly likely to be cited in any serious treatment of the BX completeness proof for strict linear time, and their absence from the existing tracked list is a significant gap. The Caleiro et al. 2013 paper is potentially the most directly relevant to the BX completeness result from a theoretical standpoint.

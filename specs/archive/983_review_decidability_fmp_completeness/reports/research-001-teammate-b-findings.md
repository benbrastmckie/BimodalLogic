# Research Report: Literature and Theory - FMP and Decidability

**Task**: 983 - Review decidability results and FMP for publication
**Teammate**: B (Literature and Theory)
**Date**: 2026-03-16
**Focus**: Standard FMP and decidability results from the literature

---

## Executive Summary

This report synthesizes the standard results from the modal and temporal logic literature on finite model property (FMP) and decidability. The key findings establish:

1. **All basic modal logics (K, K4, T, S4, S5) have FMP** and are decidable
2. **Tense logics Kt and Kt4** have FMP via filtration
3. **Filtration is the standard proof method** for FMP, with selective filtration and mosaic methods as alternatives
4. **Complexity ranges from NP-complete (S5) to PSPACE-complete (K, K4, S4)**
5. **Dense time requires careful treatment** - some fragments become undecidable

---

## 1. Standard Results by Logic Family

### 1.1 Basic Modal Logics

| Logic | Axioms | Frame Condition | FMP | Decidability | Complexity |
|-------|--------|-----------------|-----|--------------|------------|
| **K** | Distribution, Necessitation | None | Yes | Yes | PSPACE-complete |
| **K4** | K + (4): Box A -> Box Box A | Transitive | Yes | Yes | PSPACE-complete |
| **T** | K + (M): Box A -> A | Reflexive | Yes | Yes | PSPACE-complete |
| **B** | T + (B): A -> Box Diamond A | Reflexive, Symmetric | Yes | Yes | PSPACE-complete |
| **S4** | T + (4) | Reflexive, Transitive | Yes | Yes | PSPACE-complete |
| **S5** | T + (5): Diamond A -> Box Diamond A | Equivalence | Yes | Yes | **NP-complete** |

**Key Reference**: Blackburn, de Rijke, and Venema (2001) "Modal Logic" - Cambridge University Press provides the comprehensive treatment.

### 1.2 Tense Logics

| Logic | Operators | Frame Condition | FMP | Decidability |
|-------|-----------|-----------------|-----|--------------|
| **Kt** | F, G, P, H | None | Yes | Yes |
| **Kt4** | F, G, P, H | Transitive | Yes | Yes |
| **Kt.Dense** | F, G, P, H | Dense | Yes | Yes |
| **Kt.Discrete** | F, G, P, H | Discrete (N or Z) | Yes | Yes |

**Operator Definitions** (Prior's tense logic):
- **F** ("will be"): FΑ is true at t iff A is true at some future t' > t
- **P** ("was"): PA is true at t iff A is true at some past t' < t
- **G** ("always will be"): GA = ~F~A
- **H** ("always was"): HA = ~P~A

**Interaction Axioms** for Kt:
- (GP): A -> GPA ("if A now, then it will always have been that A was")
- (HF): A -> HFA ("if A now, then it has always been that A will be")

### 1.3 Combined Tense-Modal Logics

**Product logics** combining temporal and modal operators have been studied extensively:
- Gabbay & Shehtman (1998): "Products of modal logics, Part 1"
- Gabbay, Kurucz, Wolter, Zakharyaschev: Products of Kt with S5 often preserve FMP

**Complexity escalation**: Combining logics can increase complexity
- K x K: PSPACE-complete
- K4 x S5: EXPTIME-complete (Gabbay et al.)
- S4 x S5: EXPTIME-complete

---

## 2. Proof Methods

### 2.1 Filtration

**Definition**: Given a model M = (W, R, V) and a finite set Σ of formulas closed under subformulas, the filtration M* = (W*, R*, V*) is constructed by:
- W* = W/≡_Σ where w ≡_Σ v iff for all φ ∈ Σ, M,w ⊨ φ iff M,v ⊨ φ
- R* defined to preserve modal satisfaction
- V* defined on equivalence classes

**Filtration Theorem**: For all φ ∈ Σ and all w ∈ W:
  M, w ⊨ φ  iff  M*, [w] ⊨ φ

**Size Bound**: |W*| ≤ 2^|Σ| ≤ 2^n where n = |Sub(φ)|

**Consequence**: If φ is satisfiable, it is satisfiable in a model of size ≤ 2^|φ|

**Variants**:
- **Smallest filtration**: R* is minimal relation preserving truth
- **Largest filtration**: R* is maximal relation preserving truth
- **Selective filtration** (Gabbay): More refined selection for specific logics

### 2.2 Canonical Model Construction

**Definition**: The canonical model M_L for logic L has:
- W_L = {Γ : Γ is a maximal L-consistent set}
- Γ R_L Δ iff {φ : Box φ ∈ Γ} ⊆ Δ
- V_L(p) = {Γ : p ∈ Γ}

**Truth Lemma**: M_L, Γ ⊨ φ iff φ ∈ Γ

**Limitation**: Canonical models are infinite; FMP requires additional argument

**Application**: Used for completeness proofs, then combined with filtration for FMP

### 2.3 Mosaic Method

**Overview**: Decomposes models into local "tiles" (mosaics) that can be assembled

**Key Result** (Marx, Venema): The existence of a model is equivalent to the existence of a suitable set of mosaics

**Applications**:
- Many-dimensional modal logics
- Combined tense and modal logics
- Provides tableau-style decision procedures

**Reference**: "On the Mosaic Method for Many-Dimensional Modal Logics" (Logica Universalis, 2012)

### 2.4 Selection Functions / Step-by-Step Methods

Alternative to filtration for certain temporal logics, particularly those with until/since operators

---

## 3. Complexity Bounds Summary

### 3.1 Modal Logics

| Logic Class | Satisfiability Complexity | Decision Procedure |
|-------------|---------------------------|-------------------|
| K, T, K4, B, S4 | PSPACE-complete | Tableau / Filtration |
| S5 | NP-complete | Simple guessing |
| PDL | EXPTIME-complete | Automata-based |
| μ-calculus | EXPTIME-complete | Automata/parity games |

### 3.2 Temporal Logics

| Logic | Complexity | Notes |
|-------|------------|-------|
| LTL (over N) | PSPACE-complete | Sistla & Clarke (1985) |
| CTL | EXPTIME-complete | Model checking is P |
| CTL* | 2EXPTIME-complete | |
| Kt (basic tense) | PSPACE-complete | Via filtration |
| Until/Since over R | PSPACE-complete | Gabbay & Hodkinson |

### 3.3 Dense vs Discrete Time

**Discrete Time (N or Z)**:
- Kt + discreteness axioms: PSPACE-complete
- LTL over natural numbers: PSPACE-complete

**Dense Time (Q or R)**:
- Basic tense logic: Still decidable
- MTL (Metric Temporal Logic): Decidability depends on semantics
  - Event-based: Decidable (non-primitive recursive)
  - State-based: Undecidable
- TCTL with equality: Undecidable
- TCTL without equality: Decidable

---

## 4. Key References

### 4.1 Foundational Textbooks

1. **Blackburn, de Rijke, Venema (2001)**: "Modal Logic" - Cambridge University Press
   - Comprehensive treatment of FMP via filtration
   - Covers all basic modal logics
   - Standard reference for publication-quality proofs

2. **Gabbay, Hodkinson, Reynolds (1994)**: "Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1" - Oxford University Press
   - Definitive treatment of tense logics
   - Completeness and decidability proofs for Kt, Kt4
   - Dense and discrete time models

3. **Goranko & Otto (2007)**: "Model Theory of Modal Logic" - Handbook of Modal Logic
   - Advanced techniques including bisimulation
   - Filtration variants
   - Complexity analysis

### 4.2 Key Papers

1. **Sistla & Clarke (1985)**: "The Complexity of Propositional Linear Temporal Logics"
   - Established PSPACE-completeness of LTL
   - Classification of complexity by operator sets

2. **Goldblatt (1987)**: "Logics of Time and Computation"
   - Foundational work on tense logic semantics
   - Canonical models and completeness

3. **Segerberg (1970)**: "Modal Logics with Linear Alternative Relations"
   - Early completeness results for tense logics

4. **Burgess (1980)**: "Decidability for Branching Time"
   - Decidability of Peircean branching time logic
   - Gabbay Irreflexivity Rule

### 4.3 Survey Articles

1. Stanford Encyclopedia of Philosophy: "Temporal Logic" and "Modal Logic"
   - Accessible overviews with references
   - Good for understanding context

---

## 5. Publication-Quality Standards

### 5.1 What Constitutes a Complete FMP Proof

A publication-quality FMP proof must include:

1. **Clear definition of the logic**: Syntax, axioms, inference rules
2. **Semantic definition**: Kripke frames, validity conditions
3. **Soundness proof**: Axioms are valid on the frame class
4. **Completeness via canonical model**: Truth Lemma proof
5. **FMP via filtration or alternative method**:
   - Define the equivalence relation
   - Prove the Filtration Lemma (truth preservation)
   - Establish size bounds
   - Show filtrated model is in the right frame class
6. **Decidability corollary**: From FMP + finite axiomatization

### 5.2 Common Proof Patterns

**For reflexive logics (T, S4, S5)**:
- Filtration naturally preserves reflexivity
- Size bound: 2^n where n = number of subformulas

**For transitive logics (K4, S4)**:
- Must use "transitive closure" of filtration relation
- Or use selective filtration (Gabbay)

**For tense logics**:
- Handle both R and R^(-1) relations
- Filtration must preserve converse relationship

### 5.3 Gaps to Avoid

1. Assuming filtration automatically preserves all frame properties (it doesn't)
2. Forgetting to verify the filtrated model is in the right frame class
3. Incomplete treatment of interaction between past/future operators
4. Unclear handling of density/discreteness axioms

---

## 6. Confidence Assessment

| Topic | Confidence | Notes |
|-------|------------|-------|
| Basic modal logic FMP (K, K4, S4, S5) | **High** | Well-established, textbook material |
| Tense logic FMP (Kt, Kt4) | **High** | Standard results in Gabbay et al. |
| Complexity bounds (PSPACE, NP) | **High** | Sistla-Clarke and subsequent work definitive |
| Filtration method | **High** | Standard technique, well-documented |
| Dense time decidability | **Medium-High** | Some subtleties with metric temporal logics |
| Combined tense-modal logics | **Medium** | Product logic results more specialized |
| Mosaic method | **Medium** | Less commonly used, but well-established |

---

## 7. Recommendations for Publication

1. **Follow Blackburn et al. presentation style** for basic FMP proofs
2. **Cite Gabbay, Hodkinson, Reynolds** for tense logic results
3. **Be explicit about frame class preservation** in filtration proofs
4. **Distinguish clearly between**:
   - Model validity vs frame validity
   - Completeness vs FMP vs decidability
5. **Include complexity bounds** to demonstrate awareness of computational aspects
6. **For novel extensions**, compare method to existing literature

---

## Sources

- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Modal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-modal/)
- [Finite Model Property (ScienceDirect Topics)](https://www.sciencedirect.com/topics/computer-science/finite-model-property)
- [Model Theory of Modal Logic - Goranko & Otto](https://www2.mathematik.tu-darmstadt.de/~otto/papers/mlhb.pdf)
- [Modal Logic - Blackburn, de Rijke, Venema (Cambridge)](https://www.cambridge.org/core/books/modal-logic/F7CDB0A265026BF05EAD1091A47FCF5B)
- [Temporal Logic - Gabbay, Hodkinson, Reynolds (OUP)](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Completeness and decidability of tense logics closely related to K4 (JSL)](https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/abs/completeness-and-decidability-of-tense-logics-closely-related-to-logics-above-k4/6B299B692800A268C67D2EDC72791074)
- [On the Mosaic Method for Many-Dimensional Modal Logics](https://link.springer.com/article/10.1007/s11787-012-0074-5)
- [Complexity of Generalized Satisfiability for LTL (arXiv)](https://arxiv.org/abs/0812.4848)
- [Complexity of Propositional Linear Temporal Logics (Sistla-Clarke)](https://www.semanticscholar.org/paper/The-complexity-of-propositional-linear-temporal-Sistla-Clarke/dcd30f97874b2c820eb6bbf9cbc7c97ed83035d6)
- [Modal Logics with Transitive Closure: Completeness, Decidability, Filtration](http://www.aiml.net/volumes/volume13/Kikot-Shapirovsky-Zolin.pdf)
- [Decidability of Inquisitive Modal Logic via Filtrations](https://link.springer.com/article/10.1007/s11225-024-10134-0)
- [Products of Modal Logics Part 3: Products of Modal and Temporal Logics](https://link.springer.com/article/10.1023/A:1021304426509)

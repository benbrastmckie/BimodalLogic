# Teammate D: Online Search for Gap Elimination Techniques

## Novel Sources Found (not in existing literature/)

### 1. Verbrugge, de Jongh, Veltman (2004) — "Completeness by construction for tense logics of linear time"
- **URL**: https://festschriften.illc.uva.nl/D65/verbrugge.pdf
- **Relevance**: **HIGH** — directly addresses completeness for tense logic of Z (integers) using a constructive step-by-step method. Uses "adequate sets" (finite sets of formulae to which maximal consistent sets are relativized) to handle the failure of compactness over Z. This is the Amsterdam school's adaptation of the step-by-step method specifically for discrete linear time. The technique of relativizing to adequate sets may provide the key insight for proving IsSuccArchimedean: the finiteness of adequate sets constrains the constructed model to have only finitely many distinct states between any two points.
- **Available**: Freely available PDF.

### 2. Gabbay, Hodkinson, Reynolds (1993) — "Temporal expressive completeness in the presence of gaps"
- **URL**: https://projecteuclid.org/euclid.lnl/1235423709
- **Section**: Logic Colloquium '90, pp. 89-121
- **Relevance**: **HIGH** — directly characterizes "gaps" in linear orders (the omega + omega* problem). Shows Until and Since are expressively complete for Dedekind-complete flows but need Stavi connectives for flows with gaps. Introduces a "complexity" measure on gaps. Key insight: if our logic has enough expressive power (via UZ/Prior axioms), gaps should be definable and hence eliminable.
- **Available**: Behind paywall (Project Euclid / Cambridge UP).

### 3. Hirsch & Hodkinson (1997) — "Step by step — building representations in algebraic logic"
- **URL**: https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/step-by-step-building-representations-in-algebraic-logic/2D6C50D1CCDAB0CD9B2F72543662739B
- **Section**: JSL 62, pp. 225-279
- **Relevance**: **MEDIUM** — provides the game-theoretic formalization of the step-by-step method for algebraic logic (relation algebras, cylindric algebras). The two-player game characterization may offer a framework for understanding why the step-by-step construction preserves the Archimedean property: the "builder" player must respond within finitely many steps.
- **Available**: Behind paywall.

### 4. LeanLTL (Vin, ITP 2025) — "A unifying framework for linear temporal logics in Lean"
- **URL**: https://github.com/UCSCFormalMethods/LeanLTL
- **Paper**: https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2025.37
- **Relevance**: **LOW-MEDIUM** — formalizes LTL syntax/semantics in Lean 4, supports both finite and infinite traces. Does NOT prove completeness. No since/until. But demonstrates current Lean idioms for temporal logic formalization.
- **Available**: Freely available (open source + open access paper).

### 5. FormalizedFormalLogic Project — Modal logic completeness in Lean 4
- **URL**: https://formalizedformallogic.github.io/Book/
- **GitHub**: https://github.com/FormalizedFormalLogic/Foundation
- **Relevance**: **LOW-MEDIUM** — formalizes Kripke completeness for standard modal logics (K, S4, GL, etc.) in Lean 4. No temporal/tense logic yet. But their Lean patterns for canonical model construction and frame definability proofs are directly reusable.
- **Available**: Freely available.

### 6. Lentil (verse-lab) — TLA in Lean 4
- **URL**: https://github.com/verse-lab/Lentil
- **Relevance**: **LOW** — ports TLA (Temporal Logic of Actions) to Lean 4. Different framework than tense logic but shows Lean patterns for temporal reasoning.
- **Available**: Freely available.

### 7. Nichols (2017, WITHDRAWN) — "Effective Completeness for S4.3.1 with Discrete Linear Models"
- **URL**: https://arxiv.org/abs/1712.00317
- **Relevance**: **CAUTIONARY** — attempted to prove effective completeness for S4.3.1 theories with models of order type omega. The result was FALSE and the paper was withdrawn. This is instructive: constructing discrete linear models with specific order-type properties is genuinely difficult, and naive Henkin constructions can fail.

### 8. Lichtenstein & Pnueli — "Propositional temporal logics: decidability and completeness"
- **URL**: https://link.springer.com/chapter/10.1007/978-3-540-39910-0_22 (related hierarchical proof)
- **Relevance**: **MEDIUM** — provides a hierarchical completeness proof for PTL over discrete time by exploiting completeness of the "next" sublogic. The idea of reducing temporal completeness to a simpler base logic may apply: if we can show the "next-step" fragment already excludes gaps, the full logic inherits this.

## Key Technical Insights from Search

1. **Adequate sets (Verbrugge et al.)**: The failure of compactness over Z means standard canonical model constructions produce models that may not be Z-like. The fix is to work with MCS relativized to finite "adequate sets." The finiteness of adequate sets is what enforces finite intervals — exactly our IsSuccArchimedean property.

2. **Gaps are an expressiveness issue (Gabbay-Hodkinson-Reynolds)**: Gaps in a linear order (omega + omega*) are a definable phenomenon when you have sufficient temporal operators. Since our logic includes S and U plus the Prior-UZ axiom, gaps should be semantically ruled out at the frame level.

3. **Withdrawn S4.3.1 paper**: Confirms that getting order-type properties right in canonical constructions is a known hard problem where attempted proofs have been shown incorrect.

4. **No existing Lean formalization**: No project has formalized tense logic completeness (with S/U) in any proof assistant. Our work would be genuinely novel.

## Recommendation

The Verbrugge-de Jongh-Veltman paper should be prioritized for close reading. Their "adequate set" technique appears to be precisely the mechanism that ensures finite intervals in step-by-step constructions — which is the core of IsSuccArchimedean. The argument would be: at each step of the omega-chain construction, only finitely many formulae are "active" (the adequate set), so the constructed model cannot have infinitely many distinct points between any two named points.

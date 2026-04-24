# Research Report: Task #112 — Literature Study for Representation Theorem

**Task**: 112 - Systematic literature study: 5 non-original sources for task 107 representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Focus**: Relevance to three-layer infrastructure problem and hybrid approach

## Summary

Four teammates reviewed five literature sources (Burgess 1982b, Venema 1993, Obendrauf 2024, Burgess 1984, Thomason 1984) against the task 107 representation theorem's three-layer infrastructure problem: (1) trivial g-function, (2) guard convention mismatch, (3) domain density. The study reveals that **Venema 1993** and **Burgess 1984** are the highest-value sources, while the Critic identified a serious conceptual gap: the chronicle construction may be mixing three distinct proof strategies inconsistently.

### Top-Level Findings

1. **Layer 1 (g-function)**: No source provides a direct construction technique for making g non-trivial. The Critic finds that the g-function does NOT appear in Burgess 1984's basic chronicle — it belongs to period-based semantics (Burgess 1982b). The codebase's `g = ∅` reflects a theoretical mismatch, not just an implementation gap. Burgess 1982b's homogeneity requirement is a hard prerequisite.

2. **Layer 2 (guard convention)**: Venema 1993's strict-open Until semantics (`t < u < v`) exactly matches C5's open guard. The half-open [t, s) gap can be bridged via BX9 (`φ U ψ → φ ∨ ψ`), following Venema's A3a pattern. This is the most actionable finding.

3. **Layer 3 (density/domain)**: All sources confirm sparse X ⊂ Q is correct. Dense orders validate GGp→Gp (Burgess 1982b §4.3, Burgess 1984 Diodorean fragment table). Venema's model-replacement technique via Doets' theorem offers an alternative to direct construction.

4. **Hybrid approach**: Venema 1993 provides the strongest support — his "build then replace" strategy (definably-well-ordered → well-ordered via Doets' theorem) is a published instance of the hybrid idea. Thomason 1984 provides mixed evidence: T×W validity is "essentially first-order" (supports transfer), but interaction axioms (AK12: □Pp → P□p) create genuine dependencies between temporal and modal components.

5. **Critical gap (Critic)**: The BX chronicle appears to mix elements from three distinct proof strategies (Burgess 1984 pure tense chronicles, Burgess 1982b period semantics, Venema/Burgess U/S completeness). The g-function's theoretical origin is unclear, and the bimodal interaction (Thomason 1984) requires additional chronicle conditions beyond pure tense logic.

## Key Findings

### 1. Venema 1993 — Highest-Value Source (All Teammates Agree)

**Until semantics confirmation** (Teammate A, High confidence): Venema's U(φ,ψ) uses strict-open guard: "there is a v > t such that M,v ⊨ φ and for all u with t < u < v, M,u ⊨ ψ." This exactly matches C5's open guard (x < z < y). The starting point t is NOT required to satisfy ψ.

**Guard bridge via BX9** (Teammate A): BX9 gives φ U ψ → φ ∨ ψ at the starting point. If ψ holds at t, the Until is immediately satisfied. If φ holds at t, the guard at t is satisfied. Venema's axiom A3a provides the pattern for formalizing this in Lean.

**Orthodox axiom systems** (Teammate D, High confidence): Venema explicitly avoids the Gabbay-Hodkinson irreflexivity rule (IR), using only MP, TG, SUB — matching BX's orthodox derivation rules. This is a publishable advantage.

**Model-replacement technique** (Teammate B, High confidence): Build any linear model satisfying the formula, then replace with a model of the correct type using Doets' theorem. Directly supports the hybrid approach: build Int chain (easy), then argue equivalence to a model with Until/Since witnesses.

**Warning about Stavi connectives** (Critic): Venema §2.3 defines Stavi connectives U', S' for handling gaps in linear orders. The chronicle's limit construction may create gaps. Task 107 research does not mention these at all.

### 2. Burgess 1984 — Confirms Structural Framework

**Diodorean fragment table** (Teammate A, High confidence): Total orders give S4.3 Diodorean / S5 Aristotelian. Dense orders add GGp→Gp. Since BX lacks this, the chronicle must use non-dense orders.

**Augmented frames** (Teammate A): Augmented frames (X, R, F) with admissible proposition families closed under gA, hA operations provide a structural template for what g(x,y) should contain. The closure conditions on F map to C1–C5 conditions on g(x,y).

**AddCommGroup confirmed** (Teammate A, High confidence): Burgess §6.1 (Metric Tense Logic) explicitly states: "In metric tense logic we assume Time has the structure of an ordered Abelian group." The AddCommGroup constraint is mathematically correct, not a formalization artifact.

**g-function NOT in basic chronicle** (Critic, High confidence): Burgess 1984's Killing Lemma for total orders uses T(x) ⊆ B, NOT g_content(f(x)) ⊆ B. The g function does not appear in the basic G/H/F/P chronicle. It is a feature of the Until/Since extension (§4A).

### 3. Thomason 1984 — Bimodal Interaction Warnings

**Naive combinations are incomplete** (Teammate D): Formula (17) is valid in Kamp frames but NOT derivable from AK0–AK13 + RK0–RK3. The interpolation property (inserting alternative-time witnesses) is required. This justifies BX's complex axiom set (BX4–BX12).

**T×W framework** (Teammate B): BX is closest to a T×W system (shared linear time, S5 equivalence at each point). T×W validity is "essentially first-order" — supporting Venema-style model replacement. But the interaction axiom AK12 (□Pp → P□p) means temporal and modal components cannot be cleanly separated.

**The chronicle must handle bimodal interaction** (Critic, High confidence): The standard chronicle (coherent + prophetic + historic) is for PURE tense logic. For BX, additional "modal coherence" conditions are needed. The task 107 research treats the chronicle as primarily about Until/Since witnesses without discussing the Box case of the killing lemma.

### 4. Obendrauf 2024 — Lean 4 Engineering Patterns

**Five directly transplantable patterns** (Teammate B, High confidence):
1. Filtered canonical model via `Finset.attach` — applicable to limit_g construction
2. Typeclass hierarchy (`Pformula`/`CLformula`/`Kformula`) — applicable to BX parametric truth lemma
3. Three-layer datatype management (Set/Finset/List) — unavoidable for limit construction
4. Inductive path predicates built from front (`C_path.done` + `C_path.next`) — applicable to omega-chain induction
5. Consistency-parameterized canonical model — applicable to BX completeness

**Closure definition warning** (Critic, High confidence): "Small implementation choices early in the formalization process can have unintended effects later." Obendrauf had to change cl(φ) to include all subformulas of members, not just of the original formula. The BX chronicle's C3–C5 conditions may need analogous refinement.

**Scale estimate** (Teammate D): CLC completeness took ~6,000 lines. BX should expect 5,000–8,000 lines for sorry-free completeness.

### 5. Burgess 1982b — Period Semantics Context

**Homogeneity requirement** (Critic, High confidence): The period-based completeness proof works ONLY for homogeneous valuations (distributive + weakly cumulative). If the chronicle uses period semantics, g = ∅ violates homogeneity and the truth lemma cannot hold. This is deeper than Layer 1 as diagnosed — the AXIOMS governing g must enforce homogeneity.

**Interval content characterization** (Teammate A): g(x,y) should be the set of formulas holding "throughout" (x,y) — the distributive + weakly cumulative characterization from §2.3 defines this precisely.

**Dense-order warning** (Teammate A, High confidence): §4.3 shows that Q-based completeness for S (with Gp→p) uses property (3): Gβ ∈ T(x) → β ∈ T(x). The words "actually consistent with S" are load-bearing — this requires A5. Without A5 (BX), condition (3) should not hold.

## Synthesis

### Conflicts Resolved

1. **g-function origin**: Teammate A says no source provides direct fix; Critic says g has wrong theoretical basis. **Resolution**: Both are correct at different levels. The g-function's concept comes from period semantics (Burgess 1982b) but its implementation in the codebase appears to be a non-standard extension. The theoretical basis needs clarification before implementation proceeds.

2. **Hybrid approach viability**: Teammate B (strong support via Venema) vs. Thomason concerns about non-separability. **Resolution**: The hybrid is viable IF the combined structure satisfies interaction axioms. T×W being "essentially first-order" means first-order equivalence transfers modal truth, supporting the approach. But interaction axioms (AK12 type) must be explicitly verified in the combined structure.

### Gaps Identified

1. **Origin of g-function**: Which paper introduces the BX chronicle's g-function? Is it from Burgess 1982a (the original S/U paper, which we have but whose markdown may not have been studied for this specific question)?

2. **Period vs. instant semantics**: Is BX completeness for period-based or instant-based semantics? The answer determines whether homogeneity (Burgess 1982b) is relevant.

3. **Bimodal chronicle conditions**: What additional conditions does the chronicle need beyond pure tense C1–C5 to handle the S5 modality?

4. **Stavi connectives**: Does the limit construction create gaps that require Stavi-style handling?

5. **Missing literature**: Burgess 1982a markdown exists but its relevance to the g-function origin should be re-examined. Doets 1989 and Gabbay-Hodkinson 1990 are high-priority for the model-replacement technique.

### Recommendations

**For task 107 implementation plan v5**:

1. **Clarify g-function's theoretical role before fixing it** (Critical). Is it period semantics (Burgess 1982b) or Until/Since witness tracking (Burgess 1982a)? The fix depends on the answer.

2. **Layer 2 fix is actionable now**: Venema's strict-open semantics confirms C5's open guard is correct. Bridge to half-open via BX9 + a `starting_point_satisfies_guard` lemma.

3. **Layer 3 is confirmed**: Sparse X is correct. No changes needed to the plan.

4. **Add bimodal interaction verification** to the plan: The chronicle must handle Box-tense interaction (Thomason's AK12 analog). This may be implicit in the existing BFMCS construction but should be verified.

**For publication**:
- Cite Venema (1993) for orthodox axiom advantage (no IR rule)
- Cite Thomason (1984) for justifying BX's additional axioms BX4–BX12
- Cite Burgess (1984) for S5 as Aristotelian fragment of linear tense
- Cite Obendrauf (2024) for Lean 4 feasibility confirmation

**Missing literature to obtain**:
- **Doets 1989** — key to model-replacement technique (for task 68 dense completeness)
- **Gabbay-Hodkinson 1990** — IR-based completeness (to contrast with BX's orthodox approach)
- **Xu 1988** — primary reference for BX axiom simplification (publication-critical)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary (three-layer mapping) | completed | high |
| B | Alternative patterns / hybrid evidence | completed | high |
| C | Critic (gaps and blind spots) | completed | high |
| D | Strategic horizons | completed | high |

## Source Relevance Summary

| Source | Layer 1 (g) | Layer 2 (guard) | Layer 3 (density) | Hybrid | Overall |
|--------|-------------|-----------------|-------------------|--------|---------|
| Burgess 1982b | Low (homogeneity context) | Medium | High | Weak | High |
| Venema 1993 | Low | **High** | Medium | **Strong** | **Highest** |
| Obendrauf 2024 | Medium (Lean patterns) | Low | Low | Indirect | Medium |
| Burgess 1984 | Low (g not in chronicle) | Medium | **High** | N/A | High |
| Thomason 1984 | Very Low | Low | Medium | Mixed | Medium |

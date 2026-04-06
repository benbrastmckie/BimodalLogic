# Research Report: Task #83 — Until Transfer Lemma: Duration Definitions, Mathematical Structures, and Long-Term Solution

**Task**: 83 — Close Restricted Coherence Sorries
**Date**: 2026-04-05
**Mode**: Team Research (3 teammates)
**Session**: sess_1775451312_81e0d2

## Summary

Three research agents investigated whether Until can define "durations" to overcome the Until Transfer Lemma gap, whether algebraic/topological/categorical structures provide resolution paths, and what the mathematically correct long-term solution is. **All three agents independently converge on the same conclusion**: the Until Transfer Lemma is unprovable within the current incremental chain + Lindenbaum seed architecture. The root cause is a three-way mismatch between (1) Until's X-governed one-step semantics, (2) the Lindenbaum seed's G-governed consistency technique, and (3) strict temporal semantics (no T-axiom). No repackaging of Until as "durations," no algebraic structure, and no topological or categorical framework can resolve this within the current architecture. The recommended long-term solution is a **global canonical model construction** (Burgess/GHR style), with the FMP path as a secondary option at reduced confidence (50%, down from prior estimates of 85%).

## Key Findings

### 1. Until Cannot Define Durations That Overcome the Gap (Teammate A)

Teammate A thoroughly investigated five approaches to using Until for duration-based resolution:

**a) Duration formalization**: `Duration(phi, psi, M) := (phi U psi) in M` — this repackaging adds no new mathematical content. The duration concept is an X-local property (unfolds one step at a time via X), while the dovetailed chain's propagation is G-global. No amount of repackaging changes this mismatch.

**b) Enhanced seed with deferral disjunctions**: The seed `temporal_box_g_seed(M_n) ∪ {ψ ∨ (⊤ U ψ) | (⊤ U ψ) ∈ M_n, ψ ∉ M_n}` was analyzed in full detail. The consistency proof fails because deferral disjunctions are not G-liftable: G-lifting `L_seed ∪ L_d ⊢ ⊥` produces `G(¬(⊤ U ψ_i)) ∈ M_n`, which does NOT contradict `(⊤ U ψ_i) ∈ M_n` under strict semantics.

**c) Until Induction axiom**: All natural instantiations fail under strict semantics:
- `χ = (⊤ U ψ)`: requires `G(ψ → ⊤ U ψ)`, which is semantically false
- `χ = ψ ∨ (⊤ U ψ)`: requires `G(X(χ) → χ)`, invalid without T-axiom for X
- `χ = F(ψ)`: requires `G(ψ → F(ψ))`, invalid under strict semantics
- Under reflexive semantics, instantiation 3 would work perfectly — this is the T-axiom safety net that strict semantics removes.

**d) Inductive duration tracking**: The "active Until set" `AU(n) = {ψ | (⊤ U ψ) ∈ M_n, ψ ∉ M_n}` adds no information beyond what Until Unfold already provides.

**e) Fundamental impossibility theorem** (informal): No seed-based Lindenbaum approach can simultaneously include a resolution target and Until obligations under strict semantics, because:
- G-lift produces `G(¬α)`, contradicts `F(α)` — works for targets but not Until
- X-lift produces `X(¬α)`, does NOT contradict `F(α)` or `(φ U α)` — insufficient
- No other lifting technique exists in the proof system

### 2. No Algebraic/Topological/Categorical Structure Resolves the Gap (Teammate B)

**a) μ-calculus / least fixed point**: `φ U ψ = μX. ψ ∨ (φ ∧ OX)`. The fixed-point characterization provides an induction principle but does not help with seed consistency for Lindenbaum extensions.

**b) Stone duality / compactness — two-chain consistency argument (NOVEL)**:

Teammate B developed a promising new argument: embed `{(⊤ U ψ)} ∪ temporal_box_g_seed(M_n)` into `x_content(M_n)` (the deterministic successor), which is an MCS. The argument:
- Every element of `temporal_box_g_seed(M_n)` is in `x_content(M_n)` (proven via temp_4, modal_4, etc.)
- `(⊤ U ψ) ∈ x_content(M_n)` when `ψ ∉ x_content(M_n)` (by `until_persists_chain`)

**However, the argument fails at Case 2**: when `ψ ∈ x_content(M_n)`, we can have `¬(⊤ U ψ) ∈ x_content(M_n)` simultaneously (under strict semantics, having ψ now doesn't imply ψ at a strict future time). In this case `x_content(M_n)` is not a witness for consistency of `{(⊤ U ψ)} ∪ L_seed`.

Detailed analysis confirms: `X(¬(⊤ U ψ)) ∈ M_n` can coexist with `(⊤ U ψ) ∈ M_n` and `X(ψ ∨ (⊤ U ψ)) ∈ M_n`, because X is deterministic and the disjunction resolves to ψ (not ⊤ U ψ) at the next step.

**c) Knaster-Tarski, category theory, coalgebras**: All add abstraction without solving the core syntactic consistency problem. Subsumed by the μ-calculus perspective.

**d) Literature survey**: Every published completeness proof for strict-semantics temporal logic with Until uses global canonical models (Burgess 1984, GHR 1994, Verbrugge step-by-step). None use incremental chains.

### 3. Critical Analysis: Root Cause and Long-Term Solution (Teammate C)

**a) Root cause — the single deepest reason**: A three-way mismatch:
1. Until Unfold produces `X(...)`, not `G(...)`
2. Lindenbaum seed consistency requires G-liftability
3. Strict semantics prevents `G(α) → α` (no T-axiom bridge)

Under **reflexive** semantics this entire problem vanishes: `G(¬(⊤ U ψ)) ∈ M_n` would imply `¬(⊤ U ψ) ∈ M_n`, contradicting `(⊤ U ψ) ∈ M_n`.

**b) Every incremental chain fails**: Deterministic, dovetailed, Succ-based, simplified, resolving — all encounter the same X-vs-G mismatch in different forms. 20+ research rounds confirm this is not a cleverness gap but an architectural impossibility.

**c) Enhanced seed from Report 19 is logically flawed**: The argument conflates "subsets of a consistent set are consistent" with "union of consistent sets is consistent." Having `g_content ∪ until_obligations ⊆ x_content(M_n)` (a consistent MCS) does NOT prove `{target} ∪ g_content ∪ until_obligations` is consistent when `target ∉ x_content(M_n)`.

**d) FMP confidence downgraded to 50%**: The FMP path changes the problem form (finite models, pigeonhole) but faces a structurally similar temporal arrangement challenge. Constructing a linear ordering on finitely many MCS states satisfying ALL temporal coherence conditions simultaneously is the same core problem. The FMP literature for temporal logic with Until uses automata-theoretic methods not yet formalized.

**e) Family switching cannot satisfy forward_F**: The BFMCS temporal coherence conditions (forward_F, backward_P) are defined at the **family level** (within a single `fam.mcs`), not at the bundle level. The current architecture explicitly notes this: "TM temporal operators quantify over times in the SAME world history." Weakening to bundle-level would be semantically incorrect.

**f) DRM approach closest to success**: `ResolvingChain.lean` achieves sorry-free forward_F via bounded deferral within `deferralClosure`. But Until persistence through Succ steps remains open (sorry at `until_persists_through_succ`), and the truth lemma for Until requires Until persistence for the phi-holds-until-psi intermediate steps.

## Synthesis

### Conflicts Resolved

| Topic | Teammate A | Teammate B | Teammate C | Resolution |
|-------|-----------|-----------|-----------|------------|
| FMP confidence | 85% | N/A | 50% | **50-60%** — C's analysis of the structural similarity to the chain problem is compelling; the temporal arrangement challenge persists in finite models |
| Global canonical model viability | 60% | High | 85% | **80-85%** — mathematically proven approach in published literature, main risk is formalization effort |
| Hybrid deterministic + bundle | Listed as option 3 | Recommended as option 1 | Refuted (family-level constraint) | **Refuted** — C's observation that temporal coherence is family-level, not bundle-level, is decisive |
| Primary recommendation | FMP | Global/Hybrid | Global | **Global canonical model** — consensus across B and C, with A's FMP as secondary |

### Gaps Identified

1. **No concrete Lean proof sketch for global canonical model**: All teams agree it should work mathematically, but nobody produced a detailed formalization plan with Lean API specifics.

2. **DRM + U-step condition unexplored in detail**: Teammate C raised the idea of adding a U-step condition to the Succ relation (`∀ (φ U ψ) ∈ u: ψ ∈ v ∨ (φ ∈ v ∧ (φ U ψ) ∈ v)`), but the existence proof for successors satisfying this condition faces the same seed consistency challenge. This deserves deeper investigation, particularly within the DRM setting where the finite closure might help.

3. **The x_content embedding (Teammate B's two-chain argument)**: While it fails in general (Case 2), the Case 1 scenario `(⊤ U ψ) ∈ x_content(M_n)` may be more common than expected. Can we characterize WHEN Case 2 arises and handle it separately?

4. **Reflexive-to-strict transfer**: Since the problem vanishes under reflexive semantics, is there a way to prove completeness for reflexive semantics first, then transfer to strict via a semantics-shifting argument?

### Recommendations

**Primary Path: Global Canonical Model Construction (85% confidence, 40-60 hours)**

Build a Goldblatt/Burgess-style canonical model:
1. Define the Succ relation on MCSes within a box-class
2. Build a directed graph of MCSes with Succ edges
3. Prove Until persistence as a property of Succ (from Until Unfold + x_content characterization)
4. Extract ω-paths through the graph (König's/Zorn's lemma)
5. Show paths satisfy all coherence conditions (G, H, F, P, Until, Since)
6. Wire into the existing truth lemma and completeness theorem

This avoids the Until Transfer Lemma entirely because Until persistence is a property of the Succ relation between pre-existing MCSes, not of incremental Lindenbaum construction.

**Secondary Path: FMP-Based Completeness (50% confidence)**

If the global canonical model proves too costly to formalize:
1. Prove the finite model property for TM logic
2. Work with finite filtered models where Until is bounded
3. Use pigeonhole/automata arguments for F-resolution

Risks: the temporal arrangement problem may be equally hard in finite models.

**Tertiary Path: DRM with U-Step Enhancement (35% confidence)**

Explore whether the DRM's finite closure provides enough structure to prove U-step successor existence:
1. Add U-step condition to Succ relation
2. Prove existence of U-step successors within DRM
3. The finite closure may constrain the problem enough for a subset-based consistency argument

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Until as duration / task semantics | completed | HIGH | Comprehensive impossibility proof for all seed-based approaches; precise analysis of Until Induction failure |
| B | Topology / algebra / category theory | completed | HIGH | Novel two-chain consistency argument (fails at Case 2 but illuminating); definitive literature survey |
| C | Critic / blocker analysis | completed | HIGH | Root cause identification (three-way mismatch); refutation of family switching; FMP confidence downgrade |

## References

1. Burgess, J. (1984). "Basic tense logic." *Handbook of Philosophical Logic*, pp. 89-133. — Global canonical model for Until temporal logic.
2. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford University Press. — Quasimodel construction, path extraction.
3. Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes. — Reflexive semantics canonical model (illustrates where strict semantics diverges).
4. Verbrugge, R. et al. "Completeness by construction for tense logics." Amsterdam school. — Step-by-step method for discrete tense logics, finite relevant set.
5. Venema, Y. "Temporal Logic" (handbook chapter). — μ-calculus characterization of Until: `φ U ψ = μX. ψ ∨ (φ ∧ OX)`.
6. Report 20 (`20_until-transfer-lemma-gap.md`). — Self-contained exposition of the gap, definitions, all prior workarounds.

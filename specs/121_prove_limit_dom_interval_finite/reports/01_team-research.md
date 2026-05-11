# Research Report: Task #121

**Task**: Prove limitDomSubtype_Icc_finite (bounded interval finiteness)
**Date**: 2026-05-10
**Mode**: Team Research (4 teammates)

## Summary

No obtained paper contains a directly extractable proof of bounded interval finiteness for discrete omega-chain constructions. This is novel to the ProofChecker's approach of case-splitting at the limit. However, the structural ingredients for a proof are well-understood: finite chronicle stages, discrete adjacency from U(T,bot), and the inability to insert points between adjacent elements. Three proof strategies were identified; all converge on the same core mathematical argument but differ in formalization approach. The unobtained paper Reynolds 1994 "Axiomatising U and S over integer time" is the most likely source of a relevant technique.

## Key Findings

### Primary Approach (from Teammate A)

**Verbrugge 2004 is the most relevant obtained paper.** Their Z completeness proof (Theorem 6) implicitly relies on bounded regions being finite — the "middle part" between boundary points is finite, and the construction terminates in bounded regions due to the finite adequate set. However, Verbrugge constructs the discrete order directly (assigning immediate successors at odd stages), rather than building a general countable order and proving interval finiteness afterward. No paper provides an explicit proof.

**All obtained papers surveyed:**

| Paper | Relevance | What It Provides |
|-------|-----------|------------------|
| Verbrugge 2004 | HIGHEST | Step-by-step construction terminates in bounded regions; Z completeness assumes finite middle parts |
| Burgess 1982 | HIGH | Foundation: dom : Finset Rat at each stage; discrete case called "routine exercise" |
| Venema 1993 | MEDIUM | Axiom W = Prior-UZ confirms project's axiom alignment; Doets transfer not directly applicable |
| Xu 1988 | LOW | Follows Burgess exactly; no discrete interval analysis |
| Reynolds 1992 | LOW | Goes through rationals then reals; no discrete treatment |
| Caleiro et al. 2013 | LOW | Mosaic method entirely different architecture |

### Alternative Approaches (from Teammate B)

**All Mathlib paths are circular.** The dependency chain:
```
Icc_finite (SORRY) → IsSuccArchimedean → LocallyFiniteOrder → Set.finite_Icc
```
We cannot use `LocallyFiniteOrder`, `IsSuccArchimedean`, or any Mathlib lemma depending on them.

**Omega chain does NOT stabilize on bounded intervals** (contradicting Teammate A's stabilization argument). C4 counterexample elimination CAN insert points between adjacent pairs at any finite stage. The adjacency in the limit is NOT the same as adjacency at any finite stage — a pair adjacent in dom(N) may have a point inserted at stage N+1.

**Most promising alternative: Convergence argument.**
1. If [a,b] were infinite, extract a strictly increasing sequence in LimitDomSubtype
2. Embed in ℝ via ℚ ↪ ℝ; the bounded monotone sequence converges to some L
3. The limit point L creates a contradiction with the discrete structure (no accumulation points)
4. Confidence: medium — the ℚ→ℝ embedding and topological handling need care

### Gaps and Shortcomings (from Critic)

**The lemma IS true.** The discrete hypothesis prevents accumulation in bounded intervals. The key insight: once adjacency is established between two points IN THE LIMIT, no domain points can exist between them. The `dom_new_unique` property (each elimination adds at most one point) controls growth.

**Critical observation about C4 in the discrete case:** C4 counterexamples between limit-adjacent points are automatically resolved. If x and succ(x) are adjacent in the limit, then for any C4 counterexample (x, succ(x), ξ, η), the guard "∀ z between x and succ(x), ξ.neg ∈ f(z)" is vacuously true because there ARE no domain points between them. So no elimination can break limit-adjacency.

**The stabilization argument is subtler than it appears.** Adjacency at finite stages ≠ adjacency in the limit. However, the adjacency IN THE LIMIT (which is what SuccOrder describes) is stable because:
- succ(x) is defined as the C5 witness with empty guard (⊥)
- No domain point can exist between x and succ(x) in the limit (by definition of succ)
- Therefore the limit succ chain partitions LimitDomSubtype into adjacent pairs

**Estimated proof size: 200-400 lines of Lean**, needing to handle all four counterexample kinds for adjacency preservation.

### Strategic Horizons (from Teammate D)

**Icc_finite cannot be bypassed architecturally.** Six alternatives were evaluated:

| Alternative | Why It Fails |
|---|---|
| Build countermodel on LimitDomSubtype directly | valid requires AddCommGroup D; LimitDomSubtype is not a group |
| Extend limit_f to all of ℚ | Strict G-coherence breaks at gap points |
| Prove IsSuccArchimedean without Icc_finite | Would essentially reprove interval finiteness anyway |
| Use Mathlib LinearLocallyFinite | Requires IsSuccArchimedean — circular |
| Task 120 semantic redesign | Task 120 research confirms: "IsSuccArchimedean sorry has nothing to do with AddCommGroup" |
| Mosaic methods (Caleiro 2013) | Would require rebuilding entire completeness architecture (~200h) |

**Reynolds 1994 is the most relevant unobtained paper.** "Axiomatising U and S over integer time" (ICTL 1994, LNCS 827) addresses exactly the discrete case. It likely contains either: (a) a proof strategy for transferring from discrete canonical construction to ℤ, or (b) an axiom system where the transfer is trivial. **Recommendation: obtain this paper before investing heavily in proof attempts.**

## Synthesis

### Conflicts Resolved

**Stabilization argument (A vs B vs C):** Teammates disagreed on whether the omega chain stabilizes on bounded intervals.
- **A** claimed stabilization: "once adjacency is established, no insertions possible"
- **B** claimed no stabilization: "C4 can keep inserting midpoints"
- **C** clarified: adjacency at finite stages ≠ adjacency in the limit

**Resolution:** B is correct that the omega chain does NOT stabilize at finite stages (C4 insertions can continue). However, C correctly observes that adjacency IN THE LIMIT (which SuccOrder describes) is stable. The confusion arises from conflating stage-level adjacency with limit-level adjacency. For the proof, we must reason about the limit structure directly, not about stabilization of finite stages.

**Proof approach (A: stabilization vs B: convergence vs C: counting vs D: stage induction):**
All four approaches ultimately reduce to the same core fact: a discrete subset of ℚ ∩ [a,b] cannot be infinite. They differ in how they derive the contradiction:
- A: omega chain stabilization (requires proving it, which is contested)
- B: Bolzano-Weierstrass on ℝ embedding (cleanest mathematically, needs care in Lean)
- C: direct counting on omega chain stages (most mechanizable but longest)
- D: strong induction on |dom(N) ∩ (a,b]| (avoids reasoning about all of limit_dom)

### Gaps Identified

1. **No paper provides the proof.** This is novel work specific to the ProofChecker's architecture.
2. **Reynolds 1994** (unobtained) is the most likely source of relevant technique or alternative strategy.
3. **Gabbay-Hodkinson-Reynolds 1994 monograph** (unobtained) likely contains definitive treatment of discrete completeness.
4. **The convergence argument** (Teammate B's recommended approach) requires careful handling of ℚ → ℝ embedding and may need Mathlib lemmas about sequential compactness that don't exist for ℚ directly.
5. **All approaches need ~200-400 lines** — this is not a trivial lemma.

### Recommendations

**Primary recommendation:** Prove `limitDomSubtype_Icc_finite` via contradiction using the discrete structure:

1. Suppose `{x | a ≤ x ∧ x ≤ b}` is infinite
2. Extract a strictly increasing (or decreasing) sequence `s : ℕ → LimitDomSubtype` all within [a,b]
3. Each `s(n)` has a successor `succ(s(n))` with `s(n) < succ(s(n))` and no domain points between them
4. Since `s(n+1) ≥ succ(s(n))`, we get `s(n+1).val ≥ succ(s(n)).val > s(n).val`
5. The sequence `s(n).val` is strictly increasing in ℚ, bounded above by `b.val`
6. By the predecessor property at the limit point: there exists an element of LimitDomSubtype that is an accumulation point, creating a gap between it and its predecessor that contains infinitely many s(n) — contradiction with adjacency

**Alternative recommendation:** Obtain Reynolds 1994 first. If it contains a direct discrete completeness technique that avoids IsSuccArchimedean entirely, that could save significant effort.

**Fallback recommendation:** Direct omega chain counting argument (Teammate C's approach):
1. Show that in the discrete case, C4/C5 eliminations cannot insert points between limit-adjacent pairs
2. Formalize that only finitely many non-adjacent gaps exist in dom(N) ∩ [a,b] at any stage
3. Show that filling these gaps terminates

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary (literature survey) | completed | medium-high |
| B | Alternatives (Mathlib, structural) | completed | medium |
| C | Critic (gaps, risks, dead ends) | completed | medium-high |
| D | Horizons (strategic, unobtained papers) | completed | high |

## References

### Obtained Papers (in literature/)
- Burgess 1982: "Axioms for tense logic I: Since and Until" — foundation for chronicle construction
- Verbrugge 2004: "Completeness by construction" — step-by-step discrete completeness, implicitly uses bounded interval finiteness
- Venema 1993: "Since and Until" — axiom W = Prior-UZ, Doets transfer technique
- Xu 1988: "On some U,S-tense logics" — extends Burgess, notes irreflexivity non-definability
- Reynolds 1992: "Axiomatization without IRR rule" — IRR-free completeness over reals
- Caleiro et al. 2013: "Mosaic method for tense-modal" — alternative completeness architecture

### Unobtained Papers (recommended for acquisition)
- **Reynolds 1994**: "Axiomatising U and S over integer time" — DIRECTLY relevant to discrete case (Springer LNCS 827)
- **Gabbay-Hodkinson-Reynolds 1994**: *Temporal Logic* Vol. 1 — definitive reference monograph

### Codebase References
- `ChronicleToCountermodel.lean:1059-1064`: The sorry location
- `ChronicleToCountermodel.lean:1074-1111`: IsSuccArchimedean proof (uses Icc_finite)
- `ChronicleConstruction.lean:551-554`: limit_dom definition (union of finite stages)
- `ChronicleTypes.lean:380`: `dom : Finset Rat` (finite domains at each stage)
- Import `Mathlib.Order.SuccPred.LinearLocallyFinite`: provides LocallyFiniteOrder FROM IsSuccArchimedean (wrong direction for us)

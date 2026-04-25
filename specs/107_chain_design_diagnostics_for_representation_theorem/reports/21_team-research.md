# Research Report: Task #107 — Options A/B Analysis + Option C Discovery

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Session**: sess_1777082068_714076

## Summary

Definitive analysis of Options A and B, both confirmed blocked by the same root cause. A potentially breakthrough Option C discovered: the codebase has sorry-free FMP infrastructure that may shortcut the chronicle entirely, plus Venema 1993 / Reynolds 1994 provide published alternative completeness proofs for strict Until/Since logics that have never been examined.

## Key Findings

### 1. Option A Is Mathematically Blocked (Unanimous — HIGH confidence)

The enlarged seed strategy (using g_content(f(max_dom)) in C5 elimination) fails because **F(eta) cannot be propagated to f(max_dom)**. Teammate A exhaustively checked all 4 BX derivation paths:

1. Direct g_content: U(xi,eta) is NOT in g_content (Until is existential, G is universal)
2. BX4 relay: produces P(U(xi,eta)) at max_dom — P-wrapped, cannot unwrap to F(eta)
3. BX4+BX10: produces P(F(eta)) at max_dom — past-of-future, not future
4. temp_4 transitivity: gives g_content ordering but doesn't help with F

**Teammate D confirmed**: temp_4 is the ONLY G-generating axiom in BX. No axiom produces G(psi) from non-G premises. R3-maximal extensions constrain Until/Since but NOT G-content (orthogonal dimensions).

### 2. Option B Does NOT Avoid the Root Cause (HIGH confidence)

Teammate B proved: the truth lemma over limit_dom still requires g_content_chain_property for the forward G direction. Option B only eliminates the non-domain extension issue (2 of 12 sorries). The backward G direction works with existing sorry-free infrastructure (limit_F_resolution).

**Teammate B's useful finding**: limit_dom is likely order-isomorphic to Q (dense + no endpoints from seriality + C4), so a completeness theorem over limit_dom COULD satisfy the ROADMAP goal.

### 3. Lindenbaum Opacity Is Confirmed Real But Nuanced (Teammate D — HIGH confidence)

**Critical correction**: The hypothesis that g_content of a Lindenbaum extension is determined by the seed is **HALF-correct**:
- **Lower bound determined**: g_content(f(x)) ⊆ g_content(Lindenbaum(S)) always holds (forced by temp_4)
- **Upper bound NOT determined**: Lindenbaum maximality adds "noise" G-formulas beyond what S forces
- **The seed eta does NOT contribute new G-formulas** (no BX axiom derives G(psi) from non-G premises)

The lower bound means g_content can only GROW, never shrink. The upper bound means it grows uncontrollably. This is the precise characterization of the opacity.

### 4. OPTION C DISCOVERED: FMP Bridge (Teammate C — HIGH priority)

The codebase has **sorry-free FMP infrastructure** in `Theories/Bimodal/Metalogic/Decidability/FMP/`:
- `fmp_contrapositive`: valid in all closure MCS → provable (sorry-free)
- `mcs_finite_model_property`: not provable → finite countermodel exists (sorry-free)

The gap between FMP completeness and TaskFrame completeness:
- FMP gives: valid in all closure MCS → provable
- Need: valid in all TaskFrame models → provable
- Missing link: "every closure MCS is realizable in some TaskFrame" (finite realization lemma)

**This may require a much simpler construction than the full Burgess chronicle.**

### 5. OPTION C2: Venema/Reynolds Alternative Proofs (Teammate C — HIGH priority)

Published alternatives to Burgess that handle STRICT linear orderings:

| Author | Year | Technique | Strict? |
|--------|------|-----------|---------|
| Venema | 1993 | "Completeness via Completeness" | YES |
| Reynolds | 1994/1996 | Direct construction | YES |
| GHR | 1994 | Multiple techniques (book) | Various |

**Neither paper has been read** despite being directly relevant. Venema uses Dedekind completeness of the reals, avoiding omega-chains entirely. Reynolds uses a direct construction different from chronicles.

### 6. Correct Burgess Implementation Remains Viable But Risky (Teammate A)

Teammate A notes: Burgess's actual architecture (C3 as definitional, Lemma 2.6 three-way decomposition) avoids the g_content_chain_property as a standalone lemma entirely. The property emerges from the construction. But:
- Nobody has written a paper proof this works under strict semantics
- 4/4 false lemma rate demands extreme caution
- Lemma 2.6 implementation is uncharted

## Synthesis

### Conflicts Resolved

1. **"Does Option A or B solve the problem?"** — All 4 teammates: NO. Both require g_content_chain_property which is blocked by the F/G polarity mismatch. Option B saves only 2 of 12 sorries.

2. **"Is g_content determined by the seed?"** — Teammate D: partially. Lower bound yes, upper bound no. This means Lindenbaum opacity is real but the problem is specifically the UPPER bound (uncontrolled G-formula addition).

### Recommended Priority Order

**Priority 1: Read Venema 1993 and Reynolds 1994** (1 research round)
- These are published completeness proofs for STRICT Since/Until logics
- They use fundamentally different techniques from Burgess
- Could provide a workable alternative that avoids omega-chain g_content entirely
- Highest information-to-cost ratio

**Priority 2: Investigate FMP Bridge** (1 research round)
- Sorry-free FMP infrastructure already exists
- The gap (finite realization lemma) may be much simpler than the full chronicle
- Could shortcut the entire chronicle construction

**Priority 3: Correct Burgess with paper proof first** (2-3 implementation rounds)
- C3 as definitional + Lemma 2.6 is the mathematically correct path
- But requires paper proof BEFORE any Lean code
- Highest risk due to false lemma history

**Abandon**: Options A and B as currently framed. The enlarged seed / direct semantic approaches do not resolve the root cause.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Option A analysis | completed | HIGH | 4 BX paths exhausted, all fail |
| B | Option B analysis | completed | HIGH | g_content_chain_property still needed, limit_dom ≅ Q |
| C | Critic + Option C | completed | HIGH | FMP bridge discovery, Venema/Reynolds references |
| D | BX axiom analysis | completed | HIGH | g_content lower/upper bound characterization |

## References

- Venema 1993, "Completeness via Completeness" — strict Since/Until completeness
- Reynolds 1994, 1996 — direct construction for strict linear orderings
- Gabbay, Hodkinson, Reynolds 1994 — "Temporal Logic: Mathematical Foundations and Computational Aspects"
- Hodkinson & Reynolds 2007 — Handbook of Temporal Reasoning survey
- Burgess 1982 — original chronicle construction (reflexive only)

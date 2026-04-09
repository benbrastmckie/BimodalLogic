# Research Report: Task #86 — Close usf_completeness Sorry

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Mode**: Team Research (4 teammates)
**Session**: sess_1775753064_b0a100

## Summary

After 4 parallel research angles (primary approach, alternatives, critical analysis, strategic horizons), the team has reached strong consensus on two critical findings:

1. **Constant-history canonical models are structurally impossible** for the imp Case B sorry (95% confidence from all teammates). On a constant history, G(α) ≡ α semantically — you cannot build a constant-history countermodel that distinguishes `G(p) → q` from `p → q`. This is why ALL prior approaches (tasks 83-86) have failed at the backward truth lemma for G.

2. **The combined F-seed approach (reports 05-06) is mathematically false.** G does NOT distribute over disjunction. The multi-target compactness argument in report 06 Section 3.2 is incorrect. Plans based on combined F-seed will always fail.

3. **The fundamental tension**: TaskFrame G semantics is LINEAR (future times on one history). MCS G semantics is BRANCHING (all bx_le successors). Embedding branching into linear requires forward_F, which is blocked by F-seed inconsistency and F-formula non-persistence.

## Key Findings

### Finding 1: All Three Known Obstructions Are Real and Unfixable (All Teammates)

Every teammate independently confirmed all three obstructions:
- **Combined F-seed inconsistency**: Counterexample is valid (G(ψ→¬ψ'), F(ψ), F(ψ') in w)
- **F-formula non-persistence**: Lindenbaum can introduce G(¬ψ), killing F(ψ) along chains
- **Constant history backward G**: truth_at G(α) = truth_at α on constant histories (mathematical impossibility)

### Finding 2: No Alternative Shortcut Exists (Teammate B)

Six alternative approaches investigated, all reduce to the same core problem:
- FMP completeness (sorry-free module): gap is `valid φ → φ ∈ every closure MCS`, which IS the truth lemma problem
- Existing completeness modules: ALL have sorries or gaps (BaseCompleteness, DenseCompleteness, DiscreteCompleteness, Algebraic)
- Conservative extension: serves different purpose, not applicable
- Flatten reduction: backward unflatten fails (α does not imply G(α))
- Two-point model: just a short dovetailed chain, same seed problem
- FMP filtration: temporal MCS properties face same core difficulty

### Finding 3: Proof-Theoretic Approaches Are Blocked (Teammate A)

Four proof-theoretic strategies checked:
- Direct IH: vacuous in Case B (ψ not valid → ih_ψ gives nothing)
- Flattening: `⊢ flatten(χ) → χ` fails when χ contains G/H
- Alternative induction measures: imp doesn't decrease gh_depth
- Top-level contrapositive: reduces to the chain problem

### Finding 4: The Branching-vs-Linear Mismatch Is Root Cause (Teammate A, C)

The sorry arises from a fundamental architectural mismatch:
- **BXCanonical MCS semantics**: G quantifies over ALL bx_le-successors (branching tree of worlds)
- **TaskFrame semantics**: G quantifies over future times on a SINGLE history (linear)

To embed branching into linear, you need forward_F (ensure the linear history visits all relevant successors). Forward_F is blocked by Obstructions 1-2. This is the root cause across ALL 39+ research iterations.

### Finding 5: Frame.lean Sorries ARE Related (Teammate C)

The 4 Frame.lean sorries (Until/Since eventuality resolution) depend on `bx_le` linearity — the same infrastructure needed for non-constant-history canonical models. While they concern Until/Since (which USF lacks), the INFRASTRUCTURE is shared. Closing `bx_le` linearity would likely unblock both.

### Finding 6: FMP Decidability Module Is Sorry-Free (Teammate B, D)

The `Decidability/` module provides `fmp_contrapositive`: if φ ∈ every closure MCS, then ⊢ φ. Completely sorry-free. But connecting `valid φ` to `φ ∈ every closure MCS` requires the same truth lemma / canonical construction.

### Finding 7: USF Normal Form (Novel, Untested) (Teammate A)

A novel approach not previously investigated: **USF normal form theorem**. If every valid USF formula is provably equivalent to a form where `imp` only occurs between temporal-free sub-formulas, then `fragment_completeness` (sorry-free) handles everything. Confidence: 45% (speculative).

### Finding 8: Proof-Theoretic Case B Without Countermodel (Teammate C)

Instead of building a countermodel for Case B, derive `ψ → χ` directly using BX proof system properties. The BX system has temp_k_dist (G distributes over →), BX1 (G(α)→α), temp_4 (G(α)→G(G(α))), and interaction axioms. A purely proof-theoretic completeness argument would bypass the semantic gap entirely. Confidence: 60%.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Teammate D says "dovetailed chain (report 06) has 90% confidence" vs Teammates A/B/C confirming obstructions | Teammate D's assessment was written before fully processing the implementation failure. The combined F-seed IS false. The dovetailed chain approach as described in report 06 CANNOT work. However, the general architecture (non-constant histories + truth lemma) IS correct — it needs a different construction method. |
| Teammate A says "accept as genuine gap" (90%) vs Teammate C says "proof-theoretic route possible" (60%) | These are not contradictory. The semantic approach (countermodel) faces a genuine gap. A proof-theoretic approach is a different proof strategy that bypasses the gap. Both assessments are valid. |

### Gaps Identified

1. **No one has actually investigated USF normal forms.** Can every valid USF formula be reduced to one where imp only occurs between temporal-free sub-formulas? This needs a focused research spike.

2. **No one has attempted the proof-theoretic route for Case B.** Deriving `ψ → χ` directly from BX axioms without countermodels. This needs a research spike.

3. **`bx_le` linearity has never been directly targeted.** It's been treated as a byproduct of other work, but closing it first would be the most direct enabler for non-constant-history models.

### Recommendations (Prioritized)

**Tier 1: Most promising new directions (research needed)**

1. **Proof-theoretic Case B** (Teammate C's finding): Derive `⊢ ψ → χ` directly without building a countermodel. Use BX axioms (temp_k_dist, BX1, temp_4) and structural properties of derivability. This is the only approach that completely bypasses the branching-vs-linear mismatch. *Needs: focused research on proof-theoretic completeness for the G/H/box fragment.*

2. **USF normal form reduction** (Teammate A's finding): Prove every valid USF `ψ → χ` is provably equivalent to a formula where imp occurs only between temporal-free sub-formulas. Then `fragment_completeness` closes everything. *Needs: research into normal form theorems for temporal logic.*

**Tier 2: Standard approach with corrected construction**

3. **Close `bx_le` linearity in Frame.lean first** (Teammate C's finding): This unblocks non-constant-history canonical models where distinct BXPoints sit at different times. The standard truth lemma for G/H then works with a proper linear chain. *Requires: understanding what blocks `bx_le` linearity and whether it's independently provable.*

**Tier 3: Strategic alternatives**

4. **FMP-to-validity bridge** (Teammate D): The gap `valid φ → φ ∈ every closure MCS` is essentially the truth lemma in restricted form. If the restriction to closure formulas simplifies the problem, this could be easier than the full canonical construction. Low confidence (40%).

**STOP: Do not pursue combined F-seed, constant-history models, or flatten reduction. These are definitively blocked.**

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach analysis | completed | high |
| B | Alternative approaches | completed | high |
| C | Critical analysis | completed | high |
| D | Strategic horizons | completed | medium-high |

## References

### Code Locations
- Sorry site: `CanonicalEmbedding.lean:418` (imp Case B of `usf_completeness`)
- Fragment truth lemma (sorry-free): `fragment_truth_iff` at `CanonicalEmbedding.lean:213-266`
- Fragment completeness (sorry-free): `fragment_completeness` at `CanonicalEmbedding.lean:310-321`
- Single-target seed (sorry-free): `forward_temporal_witness_seed_consistent` at `WitnessSeed.lean:81-179`
- G truth in MCS (sorry-free): `G_iff_mcs` at `TruthLemma.lean:124-132`
- FMP completeness (sorry-free): `fmp_contrapositive` at `FMP.lean:206`
- Canonical task frame: `canonical_task_frame` at `CanonicalEmbedding.lean:108-135`
- Frame.lean sorries: lines 646, 668, 683, 697

### Prior Research
- Report 06 (usf-completeness-path.md): Combined F-seed approach — INVALIDATED
- Report 05 (team-research.md): Deep dive confirming enriched-seed blocked
- Report 04 (restructure-research.md): Exhaustive analysis of failed approaches
- Report 03 (team-research.md): Confirmed constant histories insufficient

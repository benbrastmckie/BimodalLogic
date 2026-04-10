# Research Report: Task #88 — Close CanonicalEmbedding:418 Sorry (Round 5)

**Task**: 88 - Close remaining BXCanonical sorries (narrowed: CanonicalEmbedding:418)
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)

## Summary

Four-teammate research wave analyzing the sorry at `CanonicalEmbedding.lean:418` in `usf_completeness`, after the implementation agent found all 6 prior approaches blocked. All teammates converged on three critical conclusions: (1) the theorem IS true and the axiom system is complete for USF, (2) the two-point WorldHistory approach has a **fundamental mathematical gap** (not just a proof-engineering issue), and (3) the most promising path is reusing the existing **Bundle architecture** where the truth lemma for {atom, bot, imp, box, G, H} is already sorry-free.

## Key Findings

### 1. The Two-Point Approach Is Definitively Blocked (All 4 teammates agree)

The backward truth bridge for `G(φ)` on a two-point history `(w, v)` gives `φ ∈ w` and `φ ∈ v`, but `G_iff_mcs` requires `φ ∈ u` for ALL `u` with `bx_le w u`. Two points cannot cover the potentially uncountable set of bx_le-successors.

Plan v4's suggestion to "use only the forward direction" (line 82) does not work because the imp case of the truth bridge is **inherently bidirectional**: the forward direction for `ψ.imp χ` requires the backward direction for `ψ` (to get `ψ ∈ w` from `truth_at ψ`). All teammates independently proved this.

**Confidence revision**: Plan v4's 75% estimate should be revised to **0%** — this is not an implementation difficulty but a mathematical impossibility.

### 2. The Theorem IS True — Axiom System Is Complete for USF (Teammate C)

Teammate C verified:
- All standard axioms for S5 + tense logic (G, H) are present: propositional (4), S5 modal (5), temporal necessitation + distribution + reflexivity + transitivity + connectedness + modal-temporal interaction
- No missing axioms for the USF fragment
- The `valid` definition (quantifying over all `LinearOrderedAddCommGroup D`) is correct
- `bx_le` is a preorder (reflexive + transitive, not antisymmetric) — correct for tense logic
- `G_iff_mcs` and `H_iff_mcs` are fully proved with no hidden assumptions
- The sorry is a proof-engineering gap, not a mathematical impossibility

### 3. Constant Histories Are Categorically Wrong for G/H Inside Imp (Teammate C)

All 6 prior approaches failed for the **same fundamental reason**: they tried to use constant histories (or near-constant histories) when the problem requires non-constant ones. On constant histories, `truth_at G(φ) = truth_at φ` — the model has no temporal structure and cannot distinguish `G(φ)` from `φ`. This is not fixable by adjusting Omega, the valuation, or the history construction within constant-history models.

### 4. Bundle Architecture Reuse Is the Most Promising Path (Teammates B, C, D)

The project has TWO completeness architectures:
1. **BXCanonical** (current): BXPoints, bx_le, constant histories → blocked for G/H in imp
2. **Bundle** (BaseCompleteness.lean): BFMCS, temporal coherent families, full canonical model → sorry-free truth lemma for {atom, bot, imp, box, G, H}

The Bundle truth lemma handles imp naturally because it embeds MCS points into a full canonical model where histories visit ALL bx_le-related points. The imp case works because `imp_iff_mcs` gives the bidirectional bridge directly in the canonical model — no structural induction needed.

**Key question**: Does the Bundle architecture's temporal coherence construction require Until/Since coherence for the G/H cases? If the Until/Since coherence conditions are only needed for Until/Since truth lemma cases (not for G/H/imp), then they are **vacuously satisfied** for USF formulas, and `usf_completeness` follows by instantiating the Bundle completeness theorem.

**Concrete first step**: Read `Bundle/TemporalCoherence.lean` and `Bundle/CanonicalConstruction.lean` to verify whether `backward_until_since_coherent` and `forward_until_since_coherent` are needed for the G/H truth lemma cases or only for Until/Since.

### 5. Proof-Theoretic Reduction Has an Open Base Case (Teammate A)

Well-founded induction on `(td_consequent, sizeOf)` can peel G/H/box from the consequent:
- `valid(ψ → G(α))` → `valid(P(ψ) → α)` → by IH: `⊢ P(ψ) → α` → lift: `⊢ ψ → G(α)`
- This uses connect_future, temporal_necessitation, temp_k_dist (all available)

**Base case** (consequent is temporal-free): split on `valid(χ)`:
- If `valid(χ)`: `fragment_completeness` gives `⊢ χ`, then `⊢ ψ → χ` by prop_s. Done.
- If `¬valid(χ)` and `¬valid(ψ)`: Both not valid, but `valid(ψ → χ)`. Need `⊢ ψ → χ`. This is exactly the standard completeness problem and requires a semantic argument (canonical model).

The base case reduces to: prove `⊢ ψ → χ` where χ is temporal-free, ψ is USF with temporal operators, and `valid(ψ → χ)`. On constant histories, `truth_at χ ↔ χ ∈ w` (fragment_truth_iff), but `truth_at ψ ≠ ψ ∈ w` when ψ contains G/H. The same backward bridge problem resurfaces.

### 6. Large D Model Construction Is Feasible but Heavy (Teammate A)

Since `valid` quantifies over ALL types D, we can instantiate with D = ℝ (or any type with |D| ≥ 2^ℵ₀). A surjective history `ℝ → BXPoint` visiting all bx_le successors would give the full bidirectional truth bridge.

**Estimated effort**: 20-40 hours of Mathlib plumbing (Real instances, cardinal arithmetic for surjection existence).
**Risk**: Standard but labor-intensive. The `canonical_task_frame`'s permissive `task_rel` makes model construction easy once D is large enough.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Team D initially assessed two-point at 40%, others at 0% | Resolved to 0% — Team D's own analysis (section 8) proved the backward bridge is required, not just forward |
| Team A proposed proof-theoretic reduction as primary | Integrated as secondary — the base case gap reduces to the same problem that Bundle solves |
| Team B Approach C vs Team D section 4 (Bundle) | Same approach described differently — merged into unified Bundle recommendation |

### Gaps Identified

1. **Bundle sorry analysis incomplete**: No teammate fully traced which Bundle sorries block USF instantiation. Need to read TemporalCoherence.lean and CanonicalConstruction.lean in detail.
2. **BFMCS construction for USF**: Whether building a BFMCS from a single MCS requires Until/Since coherence is unverified.
3. **Proof-theoretic base case**: Whether the "neither valid" sub-case can actually arise after the G/H/box peeling reductions is an open question (Team A, question 1).

### Recommendations

**Primary (70% confidence, 10-15h)**: Reuse the Bundle architecture for USF completeness.
1. Read `Bundle/TemporalCoherence.lean` — check if Until/Since coherence is needed for G/H truth lemma
2. If vacuously satisfied: prove `usf_completeness` by instantiating Bundle completeness restricted to USF
3. If not vacuously satisfied: build a simplified temporal coherence that only handles G/H (no Until/Since)

**Secondary (65% confidence, 12-20h)**: Proof-theoretic reduction + Bundle for base case.
1. Restructure `usf_completeness` to use well-founded induction on `(td_consequent, sizeOf)`
2. Handle G/H/box cases by peeling (connect_future/past + necessitation + K-dist)
3. Handle base case (temporal-free consequent) via Bundle-derived semantic argument

**Fallback (90% confidence, 20-40h)**: Large D model construction.
1. Instantiate `valid` with D = ℝ
2. Build surjective history visiting all bx_le successors
3. Prove full bidirectional truth bridge on this model
4. Close the sorry via standard contradiction

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary approach | completed | 65% | Proof-theoretic reduction with WF induction; Large D model analysis |
| B | Alternative approaches | completed | 55% | Proved bidirectional bridge is essential; ParametricRepresentation path |
| C | Critic | completed | high | Axiom completeness verified; "proof-engineering gap, not math impossibility" |
| D | Strategic horizons | completed | 70% | Bundle architecture reuse recommendation; definitive two-point debunk |

## References

- Burgess 1984, Goldblatt 1992 (completeness for tense logics)
- `G_iff_mcs` (TruthLemma.lean:124) — sorry-free bidirectional G characterization
- `H_iff_mcs` (TruthLemma.lean:137) — sorry-free bidirectional H characterization
- `fragment_truth_iff` (CanonicalEmbedding.lean:213) — sorry-free temporal-free truth bridge
- `fragment_completeness` (CanonicalEmbedding.lean:310) — sorry-free temporal-free completeness
- `BaseCompleteness.lean` — Bundle architecture completeness (sorry-free for base logic)
- `connect_future_thm`, `connect_past_thm` — BX4/BX4' axiom instances

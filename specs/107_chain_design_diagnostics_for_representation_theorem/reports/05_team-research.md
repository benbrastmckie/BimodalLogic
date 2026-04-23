# Research Report: Task #107

**Task**: Chain design diagnostics for representation theorem
**Date**: 2026-04-23
**Mode**: Team Research (4 teammates)
**Session**: sess_1776982052_4ca66a
**Round**: 5 (Literature study)

## Summary

Four teammates systematically studied Burgess 1982 and Verbrugge 2004 to identify the mathematically correct solution to the F-propagation blocker. The findings converge on a clear diagnosis and a concrete solution path.

**Root cause identified**: The project's chain construction uses a fundamentally different architecture from the literature. Burgess uses a *chronicle* with a **binary interval function** g(x,y) tracking what holds between two points; the project uses **unary** g_content(M) extracting what a single MCS demands of the future. This architectural mismatch is why the project faces the "step transfer" problem, "perpetual deferral," and F-propagation failure — none of which exist in Burgess's proof.

**The BX11 fold is the wrong tool**: Burgess does NOT use the linearity axiom (BX11/A7a) for F-resolution. He uses **direct point insertion** via Lemma 2.4 (which maps to `forward_temporal_witness_seed_consistent` in the project). The BX11 fold is used only for interpolation when inserting between existing points (Lemma 2.7). All 9 dead ends from prior research stem from trying to make the BX11 fold do something it was never designed to do.

**Gate condition before implementation**: Verify that Burgess's axioms A3a and A4a are derivable from BX1-BX12. This is a 4-6 hour check that determines whether the Burgess approach is viable.

## Key Findings

### 1. Burgess's Proof Technique (Teammate A, HIGH confidence)

Burgess builds a "chronicle" — a pair (f, g) where f maps rationals to MCS and g maps pairs to DCS (deductively closed sets). The construction is ITERATIVE: start with one point, enumerate all counterexamples to conditions C4a/C5a, fix each by inserting one new rational point, take the omega-union.

**The F-resolution mechanism (Lemma 2.10)**: When U(xi, eta) ∈ f(x) lacks a witness, Burgess applies Lemma 2.4 to create a specific consistent seed C₀ = {xi} ∪ {S(alpha, delta) : alpha ∈ A} and extends to MCS C. The interval content B is chosen MAXIMALLY with respect to the r-relation. Each obligation gets its OWN witness point — there is no attempt to propagate F-formulas through a chain.

**Key structural properties**:
- **C3 (intersection)**: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) — the interval decomposes cleanly
- **R-maximality**: g(x,y) is maximal among DCSs satisfying the r-relation — eliminates Lindenbaum non-determinism by controlling what goes into the seed
- **C5a**: Direct existence of Until witnesses — NOT derived from chain propagation

### 2. Verbrugge's Step-by-Step Method (Teammate B, HIGH confidence)

Verbrugge builds models incrementally by inserting MCS-labeled points into a growing linear order. For discrete structures (Z), the C_adequate method restricts to finite adequate sets Σ, making the state space finite.

**Key contribution to the project**: The **cyclic resolution** strategy for the infinite tail. After establishing "maximal" and "minimal" endpoints (Γ_r, Γ_l) that bound G/H variation, the remaining defects form a FIXED finite list. Cycling through k defects every k steps resolves all of them. Each resolution in the finite middle part is PERMANENT (the witness has G(phi), so no later point reintroduces the defect).

**Limitation**: Verbrugge handles only G/H/F/P — **no Until/Since**. Extending to Until/Since is an unpublished adaptation.

### 3. The Triple Gap (Teammate C, HIGH confidence)

Three precise mismatches between literature and project:

| Gap | Literature | Project | Impact |
|-----|-----------|---------|--------|
| **Semantic** | Strict Until (s > t) | Reflexive Until (s ≥ t) | BX8/BX9 invalid under strict; A3a/A4a possibly derivable under reflexive |
| **Architectural** | Chronicle with binary g(x,y) | Linear chain with unary g_content(M) | Step transfer and F-propagation problems are artifacts of the unary architecture |
| **Domain** | Q (dense, midpoint insertion) | Z (discrete, no gaps) | Midpoint insertion impossible on integers |

**The step transfer problem is an architectural artifact**: Burgess never faces it because g(x,y) directly provides guard content for the interval (x,y). The project's g_content(M) only tells you what M demands of ALL future points, not what holds on a specific interval.

### 4. Two Missing Axioms: A3a and A4a (ALL teammates, HIGH confidence)

Two of Burgess's axioms are NOT present in the BX system:

- **A3a**: p ∧ U(q,r) → U(q ∧ S(p,r), r) — connects Until and Since (the temporal connectedness axiom). Used in Lemma 2.3 to establish the r-relation.
- **A4a**: U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q) — decomposition under partial failure. Used in Lemma 2.6 for counterexample repair.

**Critical gate**: If A3a and A4a are derivable from BX1-BX12, the Burgess approach can be directly adapted. If not, the approach fails and the Verbrugge-with-Until fallback is needed.

A3a may be derivable using BX4 (connect_future) + BX8 (reflexive intro) + BX5 (self-accumulation). A4a may be derivable using BX7 (linear_until). Neither derivation has been attempted.

### 5. BX11 Fold is the Wrong Tool (ALL teammates, HIGH confidence)

Burgess does NOT use the temporal linearity axiom (BX11/A7a) for F-resolution. He uses it ONLY in Lemma 2.7 for handling Until conflicts when inserting between two existing points. The project's reliance on the BX11 enriched fold (`enriched_fwd_fold`, `resolving_enriched_fwd_exists`) for F-resolution is a deviation from the literature that introduced the perpetual deferral problem.

The correct tool for F-resolution is **direct point construction** via Lemma 2.4, which maps to the project's existing `forward_temporal_witness_seed_consistent` (sorry-free).

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Burgess vs Verbrugge as primary | **Burgess primary** — directly handles Until/Since; Verbrugge is fallback if A3a/A4a not derivable |
| Q vs Z indexing | **Q recommended** — parametric framework supports arbitrary D; Z adaptation possible but more complex |
| Effort estimate range | **105-155 hours** (D's estimate) with 60% confidence on axiom correspondence, rising to 80-85% if A3a/A4a derive |

### Gaps Identified

1. **A3a/A4a derivability** — the critical gate condition (4-6 hours to verify)
2. **Reflexive Until adaptation** — Burgess's r-relation needs adjustment for s ≥ t semantics
3. **Backward infrastructure** — need `preserving_bwd_step` (symmetric to forward; 10-15 hours)
4. **BFMCS wrapper** — converting Burgess chronicle to project's BFMCS interface (15-20 hours)

### Recommended Implementation Path

**Phase 0 (GATE, 4-6 hours)**: Derive A3a and A4a from BX1-BX12 using `lean_run_code`. This determines the entire approach.

**If gate passes** → Burgess chronicle approach (Phases 1-6, 105-155 hours):
1. Foundation: Chronicle structure, r-relation, R-maximality, Lemmas 2.2-2.3
2. Point constructor: Lemma 2.4 (the mathematical heart)
3. Until-specific insertion: Lemmas 2.7-2.8
4. Counterexample elimination: Lemmas 2.9-2.10
5. Limit and BFMCS construction
6. Integration: replace the 5 sorry sites

**If gate fails** → Modified Verbrugge + quasimodel fallback:
- Use existing quasimodel infrastructure (hintikka_step, defect_count)
- Extend with Until/Since discharge within bounded segments
- Assemble into Int-indexed FMCS

### Reusable Infrastructure (~2000+ lines sorry-free)

| Module | Lines | Reuse |
|--------|-------|-------|
| ParametricRepresentation.lean | 300 | Direct (accepts any D) |
| RestrictedParametricTruthLemma.lean | 200 | Direct |
| Completeness.lean | 152 | Direct (rewire dd_countermodel) |
| Frame.lean | 673 | Direct (MCS/BXPoint infrastructure) |
| UntilSinceCoherence.lean | — | Direct (backward_until_from_step) |
| OrderedSeedConsistency.lean | 255 | Adapt (seed construction) |
| Quasimodel/ | 1,816 | Adapt (defect tracking, sigma_signature) |

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Burgess deep study | completed | Extracted exact algorithm; mapped to project; identified g(x,y) as the critical missing piece | high |
| B | Verbrugge deep study | completed | Identified cyclic resolution and direct Lemma 4 insertion as the key insight; Path B adaptation | high |
| C | Gap analysis | completed | Identified triple gap (semantic/architectural/domain); A3a/A4a as gate condition; step transfer as artifact | high |
| D | Solution synthesis | completed | 6-phase implementation plan; effort estimate; risk assessment; axiom correspondence as highest risk | high |

## References

### Literature Sources Studied
- Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." *NDJFL* 23(4), 367-374.
- de Jongh, D., Veltman, F., Verbrugge, R. (2004). "Completeness by construction for tense logics of linear time." ILLC Amsterdam.

### Project Files Referenced
- `RootScopedChain.lean` (5 sorry sites: lines 1143, 1170, 1177, 1185, 1192)
- `Completeness.lean` (sorry-free, calls dd_countermodel)
- `ParametricRepresentation.lean` (sorry-free)
- `Frame.lean` (sorry-free, MCS infrastructure)
- `TemporalContent.lean` (g_content definition)
- `TemporalCoherence.lean` (restricted_temporally_coherent)
- `UntilSinceCoherence.lean` (step transfer)
- `Axioms.lean` (BX1-BX12)
- `Quasimodel/OracleInstantiation.lean` (quasimodel infrastructure)

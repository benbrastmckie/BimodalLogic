# Team Research Report: Establishing `until_since_coherent`

**Task**: 84 — Establish Until/Since Coherence for Bundle Completeness
**Date**: 2026-04-07
**Mode**: Team Research (3 teammates)
**Session**: sess_1775633025_627e3c

## Summary

Three teammates investigated the problem from complementary angles: primary approach verification (A), alternative paths (B), and risk analysis (C). The synthesis reveals a clearer picture than the initial task 83 research synthesis suggested, with one critical discovery and one significant opportunity.

**Critical Discovery**: The backward Until direction is the single hardest sub-problem. The enriched seed construction guarantees forward Until (85% confidence) but does NOT directly provide backward Until. All three teammates independently confirmed this asymmetry.

**Significant Opportunity**: Under BX1 (G(φ) → φ, reflexive G), `g_content(u) ⊆ u` is provable for any MCS u. This simplifies the enriched seed consistency argument to trivial (all seed elements are subsets of the MCS) and may close several stale SuccExistence.lean sorries marked "KNOWN FALSE under strict semantics."

## Key Findings

### 1. Forward Until/Since: HIGH Confidence (85%)

**Consensus across all three teammates.** The enriched seed approach works for the forward direction:

1. **Seed**: `g_content(w_n) ∪ {φ U ψ : (φ U ψ) ∈ w_n ∧ ψ ∉ w_n}`
2. **Consistency**: All elements are in `w_n` (an MCS, hence consistent). Under BX1, `g_content(w_n) ⊆ w_n`. Active Until formulas are trivially in `w_n`. So the enriched seed ⊆ `w_n` ⊆ consistent.
3. **Until persistence**: At each step, if `(φ U ψ) ∈ w_n` and `ψ ∉ w_n`, then `(φ U ψ)` is in the enriched seed. Lindenbaum extension preserves the seed, so `(φ U ψ) ∈ w_{n+1}`.
4. **Witness resolution**: Dovetailed scheduling eventually places `ψ` in the seed at some step `s`. Lindenbaum preserves it, so `ψ ∈ w_s`.
5. **Guard verification**: For all `r ∈ [t, s)`: `(φ U ψ) ∈ w_r` (by Until persistence) and `ψ ∉ w_r` (by construction, since `ψ` hasn't been scheduled yet). By BX9: `(φ U ψ) → φ ∨ ψ`, so `φ ∈ w_r`.

**No known blocker for forward direction.** This is the well-understood part.

### 2. Backward Until/Since: MEDIUM Confidence (55%)

**This is the critical unknown.** All teammates confirmed the backward direction is harder:

- **Plan v39's approach (negation unfolding)**: Proven semantically INVALID (countermodel exists)
- **Direct BX axiom derivation**: No known BX axiom combination gives `backward_until` directly
- **Chain induction approach**: Need `φ ∧ X(φ U ψ) → φ U ψ`, but no X operator in the axiom system

**Three potential approaches identified**:

**Approach B1 — BX4 + BX8 + Int linearity (Teammate A, HIGH confidence for D=Int)**:
1. Assume `¬(φ U ψ) ∈ fam.mcs t` for contradiction
2. BX4: `¬(φ U ψ) → G(P(¬(φ U ψ)))`, so `P(¬(φ U ψ)) ∈ fam.mcs s`
3. By backward_P (from `temporally_coherent`): ∃ `u ≤ s` with `¬(φ U ψ) ∈ fam.mcs u`
4. For D = Int with linear ordering: either `u ≥ t` (in the guard interval) or `u < t`
5. If `u ∈ [t, s)`: `φ ∈ fam.mcs u` (from guard) but `¬(φ U ψ) ∈ fam.mcs u` → by BX9 contrapositive, `¬φ ∧ ¬ψ ∈ fam.mcs u`. Contradiction with `φ ∈ fam.mcs u`.
6. If `u = s`: `ψ ∈ fam.mcs s` gives `(φ U ψ) ∈ fam.mcs s` by BX8. Contradiction with `¬(φ U ψ)`.

**Gap in B1**: Step 4 relies on backward_P from `temporally_coherent`. This is sorry-free for the dovetailed path (line 450) but sorry for lines 322/356. Also, the P-witness `u` satisfies `u ≤ s` but we need `u ≥ t` — this requires showing that `¬(φ U ψ)` propagating forward from `t` via G forces the P-witness to be in `[t, s]`, not earlier.

**Refinement**: From step 2, `G(P(¬(φ U ψ))) ∈ fam.mcs t`, so at the witness time `s`, `P(¬(φ U ψ)) ∈ fam.mcs s` (via forward_G/g_content propagation from `temporally_coherent`). By backward_P: ∃ `u ≤ s` with `¬(φ U ψ) ∈ fam.mcs u`. Now we need `u ≥ t`.

Actually, we can strengthen: `G(P(¬(φ U ψ))) ∈ fam.mcs t` means `P(¬(φ U ψ))` is in g_content(fam.mcs t), so `P(¬(φ U ψ)) ∈ fam.mcs r` for all `r ≥ t` (by forward_G from temporal coherence). In particular, `P(¬(φ U ψ)) ∈ fam.mcs t`. By backward_P at time `t`: ∃ `u ≤ t` with `¬(φ U ψ) ∈ fam.mcs u`. But we started with `¬(φ U ψ) ∈ fam.mcs t` so `u = t` works trivially. This is circular — we're just confirming our assumption.

**Better approach for B1**: We need to show `¬(φ U ψ)` propagates forward from `t`. From `¬(φ U ψ) ∈ fam.mcs t` and BX4: `G(P(¬(φ U ψ))) ∈ fam.mcs t`. This means `P(¬(φ U ψ))` holds at all future times. But P is existential backward — it says "¬(φ U ψ) held at SOME past time," not that ¬(φ U ψ) holds now.

The core difficulty: **`¬(φ U ψ)` does NOT propagate forward via g_content** because `G(¬(φ U ψ))` is not derivable from `¬(φ U ψ)`. This is precisely the same issue as the forward direction (Until formulas aren't G-liftable), but for the negation.

**Approach B2 — Construction-based (Teammate C)**:
Build the chain so backward Until holds by construction: ensure that whenever a semantic witness will appear in the future, the current MCS already contains the Until formula. This seems impossible because chains are built incrementally (future is unknown at construction time).

**Approach B3 — Definition weakening (Teammate C, R6)**:
Split `until_since_coherent` into forward-only and backward components. Restructure the truth lemma to handle each direction separately. The backward direction might use a different argument (e.g., MCS maximality + forward coherence after the truth lemma is partially established).

### 3. No Alternative Path Bypasses the Core Difficulty (Teammate B)

All alternatives converge on the same mathematical obstacle:

| Approach | Feasibility | Bypasses Core? |
|----------|-------------|----------------|
| DeterministicFMCS (Boneyard) | Marginal | No — forward dirs blocked, backward needs `until_intro` |
| FMP path | Blocked | No — still needs truth lemma |
| BXCanonical path | Marginal | No — same linearity obstacle |
| Direct MCS proof | Blocked | Interval semantics needs chains |
| Restricted until_since_coherent | Viable cleanup | No — simplifies, doesn't bypass |

**Key insight from Teammate B**: The Boneyard `DeterministicFMCS.lean` has backward Until/Since **already proved** (lines 485-504), but blocked on the removed `until_intro`/`since_intro` axioms. If these can be derived from BX axioms, the backward direction is immediately available.

### 4. g_content(u) ⊆ u Under BX1 (Teammate C, R5)

Under BX1 (`G(φ) → φ`, reflexive G): for any MCS `u` and `α ∈ g_content(u)`, we have `G(α) ∈ u`, so by BX1 + MCS derivation closure, `α ∈ u`. Therefore `g_content(u) ⊆ u`.

This is currently sorry in SuccExistence.lean (~line 476) and SuccChainFMCS.lean (~line 1226), marked "KNOWN FALSE under strict semantics." Under the current BX system with reflexive G, these are provable.

**Impact**: Simplifies enriched seed consistency, potentially closes stale sorries, de-risks the entire approach.

## Synthesis

### Conflicts Identified and Resolved

**Conflict 1: Enriched seed consistency**
- Teammate A: "NOT obviously provably consistent via standard G-lift" (the standard proof fails for non-G-liftable elements)
- Teammate C: "Consistency is trivial — all elements are in w_n"
- **Resolution**: Both are correct about different things. The standard G-lift proof (used for targets with `F(target) ∈ w_n`) fails when Until formulas are added. But the enriched seed WITHOUT a dovetailed target is trivially consistent (subset of w_n). The enriched seed WITH a dovetailed target (`{target} ∪ g_content(w_n) ∪ active_untils(w_n)`) needs a modified consistency argument: the target is consistent with `g_content(w_n)` by the standard G-lift, and active Untils are in w_n and therefore consistent with any subset of w_n. The question is whether `{target} ∪ active_untils` is jointly consistent. This needs separate verification.

**Conflict 2: Backward Until viability**
- Teammate A: "HIGH confidence (80%) via BX4 + BX8 + Int linearity"
- Teammate C: "MEDIUM-HIGH risk (45% failure), single hardest sub-problem"
- **Resolution**: Teammate A's B1 approach has a gap (P-witness placement). The argument requires backward_P from `temporally_coherent`, which is only sorry-free for the dovetailed path. And the forward propagation of `¬(φ U ψ)` via BX4 gives `G(P(¬(φ U ψ)))` which only tells us the negation EXISTED in the past at every future point, not that it EXISTS at any specific future point. **Teammate C's skepticism is better calibrated.** Backward direction confidence: 50-55%.

### Gaps Identified

1. **Seed consistency with dovetailed target + Until formulas**: Need explicit proof that `{target} ∪ g_content(w_n) ∪ {active Untils in w_n}` is consistent. The standard G-lift covers `{target} ∪ g_content(w_n)`. The active Untils are in w_n but are NOT G-liftable. A new consistency argument is needed for the joint set.

2. **`until_intro`/`since_intro` derivation from BX axioms**: The Boneyard DeterministicFMCS has backward Until already proved, modulo these derived rules. Deriving them from BX5+BX8+BX9 would immediately unblock backward Until for that path.

3. **Which completeness path to target**: Line 450 (dovetailed) has sorry-free temporal coherence and is the natural host. Lines 322/356 (UltrafilterChain) would need separate treatment.

## Recommendations

### Primary Strategy: Enriched Dovetailed Chain (targeting line 450)

1. **Phase 0 (De-risk, 2h)**: Prove `g_content_subset_mcs` under BX1. Close stale SuccExistence.lean sorries. Verify enriched seed consistency with dovetailed target.

2. **Phase 1 (Forward directions, 4-6h)**: Build enriched dovetailed chain. Prove forward Until and forward Since via Until persistence + dovetailing + BX9 guard extraction.

3. **Phase 2 (Backward directions, 4-8h)**:
   - **Primary**: Derive `until_intro`/`since_intro` from BX axioms (unblocks DeterministicFMCS backward proof pattern)
   - **Fallback**: BX4 + BX8 approach with Int linearity (needs `temporally_coherent` dependency)
   - **Last resort**: Split definition into forward-only + backward, restructure truth lemma

4. **Phase 3 (Wiring, 2-3h)**: Close the 3 sorry sites. Focus on line 450 first (dovetailed path, sorry-free TC). Lines 322/356 may need the `until_intro` approach or separate handling.

### Decision Points

- **After Phase 0**: If enriched seed consistency with target fails → pivot to restricting the dovetailed target to always be an Until target (avoiding joint inconsistency)
- **After Phase 2 (4h)**: If backward Until not resolved → implement R6 (split definition) and close forward-only
- **After Phase 3**: Assess lines 322/356 — close via same approach or redirect completeness through dovetailed path only

### Effort Estimate

- **Optimistic** (everything works): 12-16 hours
- **Realistic** (backward direction requires iteration): 16-24 hours
- **Pessimistic** (backward direction requires restructuring): 24-36 hours

## Teammate Contributions

| Teammate | Angle | Status | Key Finding | Confidence |
|----------|-------|--------|-------------|------------|
| A | Enriched seed analysis | Completed | Forward blocked by G-lift; backward viable via BX4+BX8 for Int | Mixed (10%/80%) |
| B | Alternative approaches | Completed | No alternative bypasses core difficulty; DeterministicFMCS backward is close | High |
| C | Risk analysis | Completed | Backward Until is critical risk (45%); g_content⊆u opportunity (70%) | High |

## References

- `TemporalCoherence.lean:466-479` — `until_since_coherent` definition
- `FrameConditions/Completeness.lean:322,356,450` — sorry sites
- `DovetailedChain.lean` — dovetailed scheduling pattern
- `SuccChainFMCS.lean:2040` — `targeted_g_content_seed_consistent`
- `Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean:477-504` — backward Until/Since proofs (blocked on `until_intro`)
- `SuccExistence.lean:476` — `g_content_subset` sorry (provable under BX1)
- BX axioms: BX1 (reflexive G), BX4 (connectedness), BX5 (self-accumulation), BX6 (absorption), BX8 (reflexive intro), BX9 (elimination), BX10 (eventuality)

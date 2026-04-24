# Research Report: Task #107 — Domain Extension Decision

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Focus**: Phase 6 domain extension: Approach A (dense domain) vs Approach B (subtype model)

## Summary

All 4 research agents converge on a clear recommendation: **Approach A (dense domain) is the only viable path**, but the domain extension is not the only blocker — a previously unidentified **guard mismatch** between the chronicle's C5 and the restricted coherence interface is equally critical. Approach B (subtype model) is definitively ruled out due to an AddCommGroup constraint that cannot be satisfied on a non-additively-closed subtype of Rat.

## Key Findings

### 1. Approach B (Subtype Model) Is Definitively Ruled Out

**Teammate B** discovered that while `FMCS D` and `BFMCS D` only require `[Preorder D]`, the parametric representation theorem (`ParametricCanonicalTaskFrame`, `RestrictedParametricTruthLemma`) requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. The chronicle's `limit_dom` is NOT closed under addition (it grows by midpoint and +1 insertions), so no subtype `{ x : Rat // x ∈ limit_dom }` can satisfy `AddCommGroup`. This rules out Approaches B and C entirely.

**Confidence**: HIGH — this is a hard type-theoretic constraint verified by grep on the actual signatures.

### 2. The Guard Mismatch Is a Critical Blocker Beyond Domain Extension

**Teammate C** identified a previously unacknowledged gap: the restricted forward Until/Since coherence (TemporalCoherence.lean) requires guards at ALL points `t ≤ r < s` (non-strict lower bound), but:

- The chronicle's C5 only guarantees guards at intermediate **domain** points
- `limit_satisfies_c5_weak` drops guards entirely (it only proves witness existence)
- Even with a dense domain, guards must be proven at every intermediate point

This means **even a perfect domain extension fix leaves the Until/Since coherence proofs incomplete** unless the guard propagation is also addressed. The guard at the starting point `t` is derivable from BX9 (`U(γ,δ) → γ ∨ δ`), but guards at intermediate points require the chronicle's g-function (C3) through `limit_g`, which doesn't exist yet.

**Implication**: `limit_g` is not just a nice-to-have for Phase 5 — it's load-bearing for the entire Until/Since integration.

### 3. Dense Domain Approach: Feasible but Complex

**Teammate A** confirmed that dense domain eliminates the forward_G/backward_H problem entirely (no non-domain points = no extension needed). The proof of `forward_G` then reduces to g_content chain propagation through intermediate domain points using existing `lemma_2_5b` and C3.

However, the complexity is substantial:
- **C4 disruption**: Density insertions can create new C4 violations (concrete counterexample provided)
- **g-function splitting**: New adjacencies require R-relation decomposition (not yet proven)
- **`lemma_2_6` gap**: Provides `g_content(A) ≤ D` but NOT `g_content(D) ≤ C` (the strong version was withdrawn as false)
- **Estimate**: 500-800 lines of new Lean proof code

**Alternative mechanism** (from A): Instead of geometric midpoints, enumerate Q directly — at step n, add q_n if not in domain. Same invariant challenges but conceptually simpler.

### 4. C4 Sub-Case 1a Is a Potential False Lemma

**Teammates C and D** both flag the C4 elimination sub-case 1a (δ ∈ both f(x) and f(y)) as a significant risk. The plan claims "C3 + r-relation prevents this sub-case from arising" but:
- No formal argument exists for this claim
- No pencil-and-paper proof has been attempted
- The pattern of 4/4 PointInsertion lemmas being false suggests hidden mathematical difficulties
- **D rates probability of being provable as-stated at 55%**

This needs paper validation before implementation effort is invested.

### 5. No Quick Wins Exist

**Teammate D** confirmed all 11 sorry sites are gated on either:
- **Tier 0**: C4 chronicle invariant propagation (2 sorries)
- **Tier 1**: Domain extension design (2 sorries — forward_G, backward_H)
- **Tier 2**: Downstream of Tiers 0-1 (7 sorries)

**Teammate C** suggested `box_stable_in_chronicle_fmcs` might be provable independently via S5 box-equivalence (all chronicle MCS are box-equivalent to A by construction). **Teammate D** disagrees, noting the proof requires forward_G for propagation. This is a **conflict** — see resolution below.

### 6. Plan Inventory Is Stale

**Teammate C** verified the actual sorry count is **11** (not 17 as in the plan inventory). Phases 1-3 and Phase 5 (C5 weak) are already done. The plan's sorry inventory at the top needs updating. The 11 remaining sorries are:
- CounterexampleElimination.lean: 2 (C4/C4' sub-case 1a)
- ChronicleToCountermodel.lean: 9 (forward_G, backward_H, box_stable, 6 coherence proofs)

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A rates dense domain MEDIUM-LOW; B,D recommend it | **Resolved**: A's rating reflects implementation complexity, not viability. All agree it's the only viable option. The real question is execution difficulty, not whether to do it. |
| C says guard mismatch is THE blocker; others focus on domain extension | **Resolved**: Both are critical. Domain extension must be fixed AND guard propagation must work. They are co-blockers, not alternatives. The guard issue makes `limit_g` essential infrastructure. |
| C says box_stable provable independently; D says it needs forward_G | **Resolved**: C's argument (S5 box-equivalence) is mathematically sound IF all chronicle MCS are box-equivalent to A. This needs verification but is likely true by construction. **Recommend attempting box_stable independently as a validation step.** |
| C says C4 1a may not need C3; D says validate on paper first | **Resolved**: Both agree it's unvalidated. The question is whether C3 prevents the sub-case or whether we need an alternative resolution. Paper validation is the agreed next step. |

### Gaps Identified

1. **`limit_g` is missing and load-bearing** — needed for guard propagation, C3 in the limit, and forward_G proof (even with dense domain)
2. **Guard at non-domain points** — even dense domain only gives guards at domain points; need to show density + C3 implies guards everywhere
3. **C4 sub-case 1a mathematical validity** — unverified claim, potential false lemma
4. **R-relation decomposition** — needed for g-function splitting during density insertion, not yet proven
5. **`claim_2_11` is a tautology** — misleading name, no semantic content, should be removed or reformulated

### Recommendations

**Phase ordering should change.** The current plan orders 4→5→6→7→8. Based on team findings:

1. **First**: Design spike for dense domain (architectural decision, not full implementation)
2. **First** (parallel): Paper-validate C4 sub-case 1a claim
3. **First** (parallel): Attempt `box_stable` proof via S5 box-equivalence
4. **Second**: Define `limit_g` (essential infrastructure for everything downstream)
5. **Third**: Implement dense domain in omega-chain
6. **Fourth**: Complete C4 elimination (with C3 now available via limit_g)
7. **Fifth**: Close forward_G/backward_H (now trivial with dense domain + limit_g)
8. **Sixth**: Close remaining 7 ChronicleToCountermodel sorries (guard propagation via limit_g + C3)
9. **Seventh**: Final verification

**Effort estimate**: 40-60 hours remaining (60-80 total). The pattern of false lemma discovery warrants a pessimistic buffer.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Dense domain feasibility | completed | medium-low | C4 disruption analysis, concrete counterexample, complexity estimate |
| B | Subtype model + alternatives | completed | high | Ruled out Approaches B/C/D; confirmed AddCommGroup constraint |
| C | Critic / gap analysis | completed | medium-high | Guard mismatch discovery, stale inventory correction, box_stable insight |
| D | Strategic direction | completed | high | Phase reordering, C4 false-lemma risk, no-quick-wins confirmation |

## References

- Burgess 1982: "Axioms for Tense Logic II: Time Periods"
- Verbrugge 2004: Comparative analysis in `reports/08_verbrugge-step-by-step.md`
- Plan v4: `plans/09_implementation-plan.md`
- Prior research: `reports/07_team-research.md`, `reports/09_team-research.md`

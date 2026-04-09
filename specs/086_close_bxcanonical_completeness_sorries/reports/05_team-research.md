# Research Report: Task #86 — Round 5 Team Research

**Task**: 86 — Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Mode**: Team Research (4 teammates)
**Session**: sess_1775748512_e71e33

## Summary

This round conducted a deep dive through all past attempts (tasks 83, 84, 85, 86), archived reports, boneyard code, and the project roadmap. The goal was to understand why completeness proof attempts keep hitting the same blockers and to identify viable paths forward.

**Critical insight**: Two distinct sorry clusters have been systematically conflated. The Frame.lean sorries (4 sites, Until/Since eventuality) are **architecturally blocked** and should not be the focus. The CanonicalEmbedding.lean:418 sorry (USF completeness, imp Case B) is **tractable NOW** via non-constant chain histories — and Phases 2-5 of the current plan were never actually attempted (the "forward_F blocker" diagnosis was premature).

## Key Findings

### 1. The Forward_F Blocker Is Real But Misapplied (ALL 4 teammates converge)

The forward_F / backward_G circularity is a genuine mathematical impossibility for chain constructions that try to derive `G(¬ψ) ∈ chain(t)` from meta-level "¬ψ at all future positions." It has appeared in 39+ research rounds across tasks 83-86 under different names.

**However**: For USF completeness (formulas without Until/Since), the forward_F problem manifests differently. The dovetailed chain construction for USF does NOT need universal forward_F — it only needs G-completeness for the specific formula being proved false. The implementation agent may have prematurely concluded Phase 2 was blocked by conflating the USF-specific chain problem with the general forward_F impossibility.

### 2. Two Distinct Sorry Clusters (Teammate C, confirmed by A and D)

| Cluster | Files | Status | Path Forward |
|---------|-------|--------|--------------|
| **A: Frame.lean** (4 sorries) | lines 646, 668, 683, 697 | Architecturally blocked (95%) | Until-induction from BX5+BX6+BX7 (untried) |
| **B: CanonicalEmbedding.lean** (1 sorry) | line 418 | Tractable NOW | Non-constant chain histories (plan Phases 2-5, never attempted) |

These must be developed on **separate tracks**. Every prior attempt that coupled them failed because the Frame.lean blockers caused the USF work to be abandoned.

### 3. What Has Been Definitively Ruled Out

| Approach | Why Ruled Out | Source |
|----------|---------------|--------|
| bx_le redefinition | Forced by G truth lemma to be g_content inclusion | Task 86 round 1, all 3 teammates |
| Dovetailed chain for Until propagation | X-vs-G mismatch is architectural | Tasks 83-86, multiple confirmations |
| Burgess-Xu Axiom 4 | Semantically invalid (half-open guard) | Task 85 report 01; Soundness.lean:397-401 |
| FMP bridge for semantic completeness | FMP provides MCS-completeness only | Task 86 rounds 1-2 |
| Well-founded induction on formula complexity for forward_F | Formula sizes increase through dependency cycle | Task 83 report 28 |
| DRM-based (restricted MCS) chains | x_content collapses in DRM chains (6 Boneyard failures) | Tasks 47-57, all same root cause |
| Decidability route (valid → decidable → sound = complete) | FMP decidability ≠ semantic completeness | Task 86 round 2 |
| BXCanonical Port (chain into BXCanonical frame) | BXPoint ordering non-linear, universal quantifiers unsatisfiable | Task 83 round 39, 95% confidence |
| Fuel-based approaches | Conflates F-nesting depth (bounded) with persistence count (unbounded) | Tasks 48, 67, 81, 83 |

### 4. Approaches Never Tried (Prematurely Abandoned)

| Approach | Source | Confidence | Notes |
|----------|--------|------------|-------|
| **Plan Phases 2-5** (non-constant chain histories for CanonicalEmbedding.lean:418) | Task 86 plan | 65% | Never attempted; stopped after Phase 1 |
| **Combined F-seed extension** (all F-obligations in one Lindenbaum seed) | Task 86 handoff Path 1 | 65% | Key lemma: `combined_F_seed_consistent` |
| **Until-induction from BX5+BX6+BX7** | Task 86 round 1 | 60% | Would close all 4 Frame.lean sorries |
| **BX6 backward derivation verification** | Task 83 round 39 | 70% | Load-bearing, never verified in Lean |
| **Full-MCS enriched-Succ chain with dovetailed scheduling** | Task 83 reports 38-39 | 65% | "Novel — never been attempted" |
| **Zorn's lemma / maximal chain** | Task 86 handoff Path 4 | 55% | Never formalized |

## Synthesis

### Conflict: Which Approach for CanonicalEmbedding.lean:418?

**Teammate A** recommends: Combined F-seed extension (Path 1 from handoff)
**Teammate B** recommends: Dovetailed chain history (quasimodel restricted to USF)
**Teammate C** recommends: Attempt plan Phases 2-5 directly (never tried)

**Resolution**: These are not actually in conflict. The dovetailed chain history (Teammate B) IS plan Phases 2-5 (Teammate C). The combined F-seed extension (Teammate A) is a strengthening of Phase 2's chain construction that would make forward_F trivially true by construction.

**Recommended hybrid**: Re-attempt plan Phases 2-5, but with the combined F-seed modification at the chain construction step. Specifically:
1. Phase 2: Build `dovetail_chain` using combined F-seeds (all pending F-obligations in each Lindenbaum seed) instead of one-at-a-time scheduling
2. Phases 3-5: Proceed as planned (history wrapping, Omega, truth lemma, sorry closure)

The key enabling lemma is `combined_F_seed_consistent`:
```
∀ w : BXPoint, ∀ L : List Formula,
  (∀ ψ ∈ L, F(ψ) ∈ w.formulas) →
  SetConsistent (L.toFinset ∪ g_content(w.formulas))
```
Proof: standard compactness + temporal duality argument (Goldblatt 1992 §6.5). ~50-100 LOC.

### Conflict: Are Frame.lean Sorries Closeable?

**Teammates A, B, D**: Frame.lean sorries are architecturally blocked (95% confidence)
**Teammate C**: Until-induction from BX5+BX6+BX7 might close them (60% confidence)

**Resolution**: Not in conflict — the 95% assessment applies to chain-based approaches. Until-induction is a different approach (axiom-level derivation, not model construction). It should be attempted as a separate track (Priority 3) after USF completeness is closed.

### Gaps Identified

1. **BX6 backward derivation** (`¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))`) has never been verified in Lean despite being load-bearing for multiple approaches. This should be verified immediately (1-2 hours).

2. **The "premature blocking" hypothesis** (Teammate C): The implementation agent declared Phase 2 blocked after encountering forward_F concerns, but the USF-specific chain may not actually require universal forward_F. This needs empirical testing by attempting the implementation.

3. **ROADMAP.md is severely outdated** — does not reflect 39 rounds of task 83 research, task 85 x_content discovery, or the fragment-first strategy.

## Recommended Priority Order

**Priority 1 (IMMEDIATE, 8-12 hours)**: Re-attempt plan Phases 2-5 with combined F-seed modification.
- Phase 2: `dovetail_chain` with combined F-seeds
- Phase 3: `dovetail_history` + `dovetail_omega`
- Phase 4: Bidirectional truth lemma by USF structural induction
- Phase 5: Close sorry at CanonicalEmbedding.lean:418

**Priority 2 (1-2 hours)**: Verify BX6 backward derivation in Lean. Load-bearing, quick test.

**Priority 3 (4-8 hours)**: Attempt Until-induction derivation from BX5+BX6+BX7. If successful, closes all 4 Frame.lean sorries.

**Priority 4**: Fix BX temp_4 derivations (4 sites, low effort).

**Priority 5**: Update ROADMAP.md with findings from this research (proposed text in Teammate D findings).

## Strategic Direction (from Teammate D)

Adopt **fragment-first publication strategy**:
1. Sorry-free decidability (FMP) — ready NOW
2. USF fragment completeness (BXCanonical) — ready after task 86
3. Full representation theorem — enriched chain construction (future work)

## What to STOP Doing

1. Do NOT attempt another architectural replacement before exhausting current BXCanonical for USF
2. Do NOT couple USF completeness and full completeness in the same implementation phase
3. Do NOT re-research Frame.lean sorries with yet another structural approach
4. Do NOT attempt well-founded induction on formula complexity for forward_F
5. Do NOT build DRM-based or restricted MCS chains
6. Do NOT try to derive/add Burgess-Xu axiom 4

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Past attempts deep dive | completed | high (diagnosis), medium-high (recommendation) |
| B | Alternative approaches evaluation | completed | high (quasimodel/USF viability) |
| C | Critic — circular patterns | completed | high (pattern detection), medium (blind spots) |
| D | Strategic horizons + ROADMAP.md | completed | high (strategy), medium (enriched chain timeline) |

## References

- Task 83 reports (39 rounds): `specs/archive/083_close_restricted_coherence_sorries/reports/`
- Task 85 reports: `specs/085_until_since_chain_coherence/reports/`
- Task 86 reports 01-04: `specs/086_close_bxcanonical_completeness_sorries/reports/`
- Task 86 handoff: `specs/086_close_bxcanonical_completeness_sorries/handoffs/01_forward-f-blocker.md`
- Goldblatt 1992, §6.5 (combined F-seed consistency argument)
- Burgess 1984 (temporal canonical model construction)
- GHR 1994 (quasimodel technique)

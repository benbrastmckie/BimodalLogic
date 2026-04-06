# Research Report: Task #83 — Reflexive Semantics Switch Analysis

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Mode**: Team Research (3 teammates)
**Session**: sess_1775510047_afab29

## Summary

Three research agents (mechanism analyst, migration cataloger, critic) investigated switching from strict to reflexive temporal semantics. The synthesis resolves a critical conflict between teammates and produces a nuanced recommendation.

**Core finding**: Switching to reflexive semantics IS the correct direction — the literature uniformly requires it, and the T-axiom provides the missing seed consistency argument. However, the T-axiom does NOT fix the deterministic chain's forward_F sorry directly. It fixes the *Lindenbaum construction's* F-witness seeding problem, which was the original blocker under reflexive semantics before Task 81. The key insight is that the project now has infrastructure (deterministic chain for G-propagation, targeted chain for F-resolution) that did NOT exist during the original reflexive attempt, making the combination viable.

## Key Findings

### 1. The T-Axiom Mechanism (Teammate A)

The T-axiom G(φ)→φ breaks the forward_F circularity through **seed consistency for Lindenbaum extensions**, NOT through the deterministic chain:

| Approach | forward_F under strict | forward_F under reflexive |
|----------|----------------------|--------------------------|
| Deterministic chain (x_content stepping) | CIRCULAR (needs backward_G needs forward_F) | **STILL CIRCULAR** (same dependency) |
| Lindenbaum extension (g_content seed) | BLOCKED (¬ψ can be in g_content when F(ψ) ∈ M) | **RESOLVED** (T-axiom ensures ¬ψ ∉ g_content when F(ψ) ∈ M) |
| Hybrid (deterministic + Lindenbaum detours) | Not attempted under strict | **VIABLE** (standard literature approach) |

The precise mechanism: If F(ψ) ∈ M, then ¬G(¬ψ) ∈ M, so G(¬ψ) ∉ M (by MCS), so ¬ψ ∉ g_content(M). Therefore {ψ} ∪ g_content(M) is consistent (since ¬ψ cannot be derived from g_content(M) alone — if it could, G(¬ψ) would be in M by G-closure). A Lindenbaum extension of this set yields an MCS containing ψ as the F-witness.

**Critical nuance**: This argument uses g_content(M) ⊆ M (T-axiom direction: G(φ)→φ). The reverse direction (M ⊆ g_content(M), i.e., φ→G(φ)) is NOT valid and was incorrectly claimed in some prior analysis.

### 2. Migration Scope (Teammate B)

**24-30 files affected**, decomposed as:

| Category | Files | Lines Changed | Type |
|----------|-------|---------------|------|
| Core definitions (Truth.lean, Formula.lean) | 2 | ~80 | Mechanical |
| Axiom system (add T-axioms) | 1 | ~60 | Structural |
| Soundness proofs | 4 | ~240 | Mechanical + New |
| FMCS infrastructure | 4 | ~100 | Mechanical |
| Completeness constructions | 5 | ~550 | Structural |
| FMP path (restore from Boneyard) | 3 | ~130 | Restore |
| Cleanup (comments, docs) | ~50 | ~500 | Mechanical |
| **Total** | **~30** | **~1,660** | **Mixed** |

**Boneyard recovery**: 3 archive files (~300 lines) contain code that worked under reflexive semantics. The TargetedChainArchive.lean has exact patterns needed — sorries at `temp_t_future` references become T-axiom invocations.

**Key design decision**: Until/Since should keep STRICT witnesses (`s > t`) while G/H become reflexive (`s ≥ t`). This is standard mixed semantics (Burgess 1984, GHR 1994). Until Unfold, Intro, and Induction axioms remain unchanged.

### 3. Critical Analysis (Teammate C)

**7 gaps identified**, 3 claims verified:

| Claim | Verified? | Notes |
|-------|-----------|-------|
| "g_content(M) contains M" | **REVERSED** — g_content(M) ⊆ M, not M ⊆ g_content(M) | T-axiom direction is G(φ)→φ, giving the subset, not superset |
| "x_content ⊆ g_content" | **FALSE** — g_content ⊆ x_content (correct direction) | G(φ)→X(φ), not X(φ)→G(φ) |
| "T-axiom makes seed consistency work" | **CORRECT** | Verified: F(ψ) ∈ M implies ¬ψ ∉ g_content(M), enabling consistent Lindenbaum extension |

**Historical circular risk**: The project switched FROM reflexive TO strict in Task 81 to escape the "independent extension problem." Switching back risks re-encountering it. However, the critic acknowledges that the infrastructure has evolved significantly since Task 81.

**Recommendation**: CONDITIONAL — prototype the key lemma before committing.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate B | Teammate C | Resolution |
|----------|-----------|-----------|-----------|------------|
| Does T-axiom fix deterministic chain's forward_F? | NO — requires Lindenbaum construction | YES — archived targeted chain shows pattern | Uncertain — same fundamental obstacle? | **Teammate A is correct for pure deterministic chain; Teammate B is correct for hybrid approach**: the T-axiom fixes Lindenbaum seed consistency, and the existing deterministic chain handles G-propagation. Combined as a hybrid (targeted chain), both problems are addressed. |
| Will independent extension problem recur? | Implicitly no (Lindenbaum construction resolves it) | No (deterministic chain handles inter-MCS propagation) | YES (40-60% likely) | **The key resolution**: The original independent extension problem was that G-formulas don't propagate across independent Lindenbaum extensions. The deterministic chain (x_content stepping) SOLVES this for the default case. Lindenbaum extensions are only used for F-witness detours, where G-propagation is handled by g_content ⊆ seed. The combination avoids the original problem. |
| Scope of regression | ~40-50% of Algebraic/ replaced | 24-30 files, ~1660 lines | 20-30 theorems need re-verification, 5-10 break | **Synthesis**: Teammate B's detailed catalog is the most reliable. Teammate C's 5-10 breakage estimate is conservative but prudent. The deterministic chain infrastructure is NOT replaced — it is AUGMENTED with T-axiom support. |

### The Resolution of the Historical Cycle

The apparent circularity (reflexive → strict → reflexive) is NOT a true circle because the project's infrastructure has evolved:

| Era | Semantics | Construction | Problem |
|-----|-----------|-------------|---------|
| Pre-Task 81 | Reflexive | Lindenbaum extensions (independent) | G-propagation across independent extensions |
| Task 81-83 | Strict | Deterministic chain (x_content) | F-resolution in deterministic chain |
| **Proposed** | **Reflexive** | **Hybrid (deterministic + Lindenbaum detours)** | **Neither problem applies** |

The hybrid approach uses:
1. **Deterministic chain** (x_content stepping) as the DEFAULT successor — handles G-propagation, Until persistence, and MCS linkage (all sorry-free)
2. **Lindenbaum detours** (g_content seed + F-witness) ONLY for F-resolution — enabled by T-axiom ensuring seed consistency
3. **T-axiom** for the reflexive case (t = t') in FMCS forward_G/backward_H fields

This is exactly the pattern in the archived TargetedChainArchive.lean, which was implemented but not completed because the T-axiom was removed when switching to strict semantics.

### Gaps Identified

1. **Until persistence through Lindenbaum detours** (from Report 24, confirmed by Teammate A): When the chain takes a detour for F-resolution, the successor is a Lindenbaum extension of g_content, NOT x_content. Until obligations (φ U ψ) may not persist because they live in x_content, not g_content. This needs a specific solution — either include Until obligations in the seed, or prove they propagate through g_content.

2. **No prototype yet**: All analysis is theoretical. A small-scale proof of the seed consistency argument in Lean would decisively resolve whether the approach works.

3. **Exact axiom list**: The complete axiom system under mixed semantics (reflexive G/H, strict U/S) needs to be specified and verified against published references.

### Why This Is Different From Previous Attempts

The crucial difference from all 25 prior research rounds: **prior rounds tried to make the deterministic chain alone work**. The synthesis recommends abandoning that constraint and using a hybrid construction where:
- The deterministic chain provides the backbone (G/H coherence, Until persistence)
- Lindenbaum detours provide F-witnesses (enabled by T-axiom)
- The T-axiom handles the reflexive case in FMCS fields

This is the standard approach in the literature (Burgess 1984, GHR 1994), adapted to the existing codebase infrastructure.

## Recommendations

### Ordered by Priority

1. **Prototype the seed consistency lemma** (HIGH priority, 2-3 hours): In a scratch Lean file, prove: "If F(ψ) ∈ M (MCS) and T-axiom is in the proof system, then {ψ} ∪ g_content(M) is consistent." This is the single most important verification before committing to the switch.

2. **Resolve Until persistence through detours** (HIGH priority, research): Determine how (φ U ψ) obligations persist when the chain takes a Lindenbaum detour. Three possible solutions:
   - Include Until obligations in the Lindenbaum seed (alongside the F-witness)
   - Prove Until obligations are in g_content when they should be (requires G(φ U ψ) ∈ M)
   - Use fair scheduling to ensure detours are rare enough that Until obligations resolve between detours

3. **Switch to mixed semantics** (HIGH priority, after prototype): Change G/H to reflexive (≥), keep U/S strict (>), add T-axioms. This is the standard convention and minimizes axiom changes. Follow Teammate B's 7-phase migration plan.

4. **Restore Boneyard code** (MEDIUM priority, during migration): The TargetedChainArchive.lean contains the hybrid chain pattern. Restore and adapt to current infrastructure.

5. **Close forward_F/backward_P** (the payoff): With the T-axiom and hybrid construction, the deterministic_forward_F sorry reduces to: "the hybrid chain eventually resolves every F-obligation." This follows from fair scheduling + seed consistency + finite subformula closure.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Mechanism analysis | completed | MEDIUM-HIGH | T-axiom fixes Lindenbaum seed consistency, not deterministic chain directly; requires architecture change |
| B | Migration catalog | completed | MEDIUM-HIGH | 24-30 files, ~1660 lines; Boneyard has recoverable code; mixed semantics (reflexive G, strict U) recommended |
| C | Critical analysis | completed | MEDIUM-HIGH | 7 gaps identified; historical cycle risk is real but mitigated by evolved infrastructure; prototype before committing |

## References

1. Burgess, J.P. (1982/1984). "Axioms for tense logic: I. 'Since' and 'Until'" / "Basic Tense Logic." — Reflexive semantics, completeness proof for Until/Since over ℤ.
2. Venema, Y. (1993). "Derivation rules as anti-axioms in modal logic." JSL 58(3). — Extends Burgess-Xu framework with reflexive semantics.
3. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic*. Oxford. — Quasimodel-based completeness with reflexive semantics.
4. Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI. — Reflexive temporal semantics reference.
5. Codebase: DeterministicFMCS.lean (sorries), DeterministicChain.lean (sorry-free backbone), TargetedChainArchive.lean (hybrid pattern), CanonicalConstructionArchive.lean (Lindenbaum pattern).
6. Prior reports 01-25 for task 83.

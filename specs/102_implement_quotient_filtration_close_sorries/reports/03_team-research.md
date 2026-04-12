# Research Report: Task #102 (Round 3)

**Task**: 102 - Implement defect-discharge chain and close Until/Since sorries
**Date**: 2026-04-11
**Mode**: Team Research (4 teammates)
**Session**: sess_1775956728_4690a5

## Summary

Round 3 research deeply investigated the fundamental nature of the bx_le non-totality problem, following the user's directive to reflect carefully on what it means that "bx_le is a preorder (not total), and non-G formulas cannot propagate through it." Four teammates independently converged on a critical insight: **the problem is not a technical gap that can be patched, but an architectural mismatch between what bx_le captures (safety/invariant preservation via G-formulas) and what Until requires (liveness/eventuality with guards over arbitrary formulas).** Standard completeness proofs resolve this by building models where ordering is positional (total by construction), not information-theoretic (g_content inclusion).

Three viable paths forward were identified and ranked. The finite model bypass approach (avoiding Frame.lean entirely) emerged as the highest-confidence path, potentially closing 11 sorries simultaneously.

## Key Findings

### 1. Root Cause: Safety vs Liveness Mismatch (Teammates A, C, D)

**Confidence: HIGH (90%)**

The root cause is deeper than "bx_le is non-total." bx_le is an **information ordering** (domain-theoretic approximation): `bx_le w v` means every G-invariant at w is respected at v. This captures **safety** (invariant preservation). Until requires **liveness** (eventual satisfaction with guards over arbitrary formulas). The guard condition `∀ u, bx_le w u → bx_lt u v → φ ∈ u` ranges over ALL BXPoints in a partially ordered "interval" that admits "junk" points — BXPoints arising from Lindenbaum extensions of unrelated seeds that are bx_le-intermediate but have no semantic counterpart in a linear model.

Standard proofs (Burgess 1984, Goldblatt 1992) resolve this by building models where the ordering is **positional** (chain index), not defined by g_content. The g_content property is then a CONSEQUENCE of construction, not the definition.

### 2. The Frame.lean Sorries Are Likely Unprovable As Stated (Teammates A, C)

**Confidence: HIGH (80%)**

The 4 Frame.lean sorry signatures quantify over ALL BXPoints strictly between w and v in the bx_le ordering. On a non-total preorder, this "interval" contains points that no axiom-based argument can reach. The soundness proof reveals the gap explicitly: `SoundnessLemmas.lean:1249` uses `le_or_lt` (totality of the time domain D), which has no canonical-model counterpart.

Teammate B disagrees, arguing BX7 compensates for non-totality formula-by-formula. However, Teammate C demonstrates that BX7 is a **local** axiom (applies at one point) while the proof needs to relate formulas **across** different bx_le-related points. BX7 cannot be applied across points. This resolves the conflict: BX7 constrains ordering of witnesses at a single point but cannot propagate guard formulas between distinct points.

### 3. Derived Unfolding Theorem (Teammates C, D independently)

**Confidence: HIGH (100%)**

`(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))` is derivable from BX1 + BX9:
- BX9: `φ U ψ → φ ∨ ψ`
- BX1 (contrapositive): `φ U ψ → F(φ U ψ)` (if G(¬(φ U ψ)) held, BX1 gives ¬(φ U ψ), contradiction)
- Combining: `φ U ψ → ψ ∨ (φ ∧ F(φ U ψ))`

This is the reflexive-semantics analogue of the classical X-based unfolding. However, alone it is insufficient: it provides no decreasing measure and the guard problem persists (the guard ranges over all intermediate BXPoints, not just chain members).

### 4. BX7 Analysis for G-Persistence (Teammate C)

**Confidence: MEDIUM (65%)**

Teammate C attempted to derive `φ U ψ → G(φ U ψ)` (which WOULD solve everything by making Until propagate through bx_le). Using BX7 on `((φ ∧ (φ U ψ)) U ψ)` and `(⊤ U ¬(φ U ψ))`:

- **D1**: eventuality `ψ ∧ ¬(φ U ψ)` contradicts BX8 (`ψ → φ U ψ`). Eliminated.
- **D3**: eventuality `(φ ∧ (φ U ψ)) ∧ ¬(φ U ψ)` is directly contradictory. Eliminated.
- **D2**: gives back `(φ ∧ (φ U ψ)) U ψ` (already had from BX5). No new information.

Result: BX7 eliminates 2 of 3 disjuncts but the surviving case is vacuously true. `φ U ψ → G(φ U ψ)` remains unproved. This is the closest any analysis has gotten to a direct proof.

### 5. Factual Corrections (Teammate C)

**Confidence: HIGH (95%)**

- **Box sorry at Frame.lean:440 does NOT exist**: Lines 444-498 contain a complete S5 proof using modal_5_collapse. The ROAD_MAP sorry count is stale.
- **BXPoints are NOT restricted to enrichedClosure**: They are unrestricted MCSs (Frame.lean:49). Only HintikkaPoints are Sigma-restricted.
- **Realization.lean sorries are NOT independent from Frame.lean** (correcting Round 2 Critic): They prove the same mathematical statements. Close either set and delete the other.

### 6. The Finite Model Bypass (Teammate D)

**Confidence: MEDIUM-HIGH (60%)**

Rather than proving Frame.lean sorries as stated, build an independent finite model:
1. Define `FiniteChainModel` from defect-discharge chains (position ordering = total by construction)
2. Prove Until truth lemma trivially in this model
3. Embed as TaskModel over `Fin n`
4. Wire directly into `Completeness.lean`

This would **bypass Frame.lean entirely** (leaving its sorries as dead code) and potentially close **11 sorries simultaneously**: 4 Frame.lean + 6 Realization.lean + 1 Completeness.lean TaskModel embedding. If the box sorry is indeed already closed, this reduces the active-path sorry count to 0.

Estimated effort: 25-35 hours. Comparable to the current plan's Phase 4-alt + Phase 5 total, but closes MORE sorries with HIGHER confidence.

## Synthesis

### Conflicts Resolved

**Conflict 1: Does Burgess use g_content ordering?**
- Teammate A: Burgess uses chain/position ordering, NOT g_content inclusion
- Teammate B: Burgess uses the same g_content-based preorder as this codebase
- **Resolution**: Both are partially right. Burgess DEFINES a preorder using g_content (as in this codebase) but his completeness proof constructs SPECIFIC chains where the ordering happens to be positional. The key difference is proof strategy, not definition. The codebase's error is trying to prove Until properties for ALL BXPoints under the preorder, rather than building specific chains.

**Conflict 2: Are Frame.lean sorries provable?**
- Teammate A: Almost certainly NOT provable as stated (HIGH confidence)
- Teammate B: BX7 might work; gives detailed sketch (MEDIUM confidence)
- Teammate C: BX7 is local, cannot propagate across points; derives near-miss for G-persistence
- **Resolution**: Teammates A and C are more convincing. The BX7 case analysis (Teammate B Section 10) has a residual gap at Step 5 — showing that u is before the psi-witness requires the same totality that's missing. Teammate C's D2 survival analysis confirms BX7 alone is insufficient. The sorries are likely unprovable as stated, though a subtle argument combining BX5+BX7+BX4 remains conceivable (10-20% probability).

**Conflict 3: Finite model confidence**
- Teammate A: 80%+ for quasimodel approach
- Teammate C: 55% for closing Frame.lean / 75% for alternative completeness
- Teammate D: 60% for finite model bypass
- **Resolution**: The confidence depends on what "success" means. For closing Frame.lean AS STATED: 30% (the lifting problem from finite model to infinite canonical model is real). For an alternative completeness proof that bypasses Frame.lean: 65-70%. The finite model bypass is the higher-confidence path.

### Gaps Identified

1. **Backward direction of inductive truth lemma**: `φ ∧ F(φ U ψ) → φ U ψ` has not been verified as derivable. Teammate C began the analysis but did not complete it. This is critical for an inductive reformulation of the truth lemma.

2. **TaskModel embedding from finite chain**: No one fully worked out how to construct a `TaskModel` from a finite chain of Hintikka points. The key question: how do you define `history : Ω → D → W` when D is `Fin n` and W is the chain members? This needs investigation.

3. **Whether all active-path sorries can truly be closed simultaneously**: The finite model bypass claims 11 sorries, but this depends on the box sorry being already closed (needs verification) and the TaskModel embedding being achievable.

### Consolidated Recommendations (Ranked)

**Path 1: Finite Model Bypass (RECOMMENDED)**
- Build independent finite model with position-based total ordering
- Bypass Frame.lean entirely, wire into Completeness.lean
- Estimated effort: 25-35h
- Confidence: 65% for complete success
- Closes: potentially 11 sorries (all remaining active-path)
- Risk: TaskModel embedding complexity

**Path 2: Inductive Truth Lemma Reformulation**
- Use derived unfolding `φ U ψ → ψ ∨ (φ ∧ F(φ U ψ))` as truth lemma basis
- Requires proving backward direction: `φ ∧ F(φ U ψ) → φ U ψ`
- Reformulate `until_iff_mcs` to use this characterization
- Estimated effort: 8-15h
- Confidence: 40% (backward direction is uncertain)
- Closes: 4 Frame.lean sorries (Realization follows by delegation)
- Risk: backward direction may not be derivable

**Path 3: BX5+BX7 Combined Argument (LONG SHOT)**
- Attempt to close Frame.lean sorries directly using self-accumulation + linearity
- Build on Teammate C's near-miss (D1 and D3 eliminated, need to force D2 contradiction)
- Estimated effort: 4h time-box
- Confidence: 15%
- Closes: 4 Frame.lean sorries if successful
- Risk: high probability of failure; BX7 appears fundamentally insufficient

## Strategic Recommendation

**Pursue Path 1 (Finite Model Bypass) as primary, with Path 3 as a cheap prelude.**

Rationale: Path 3 is cheap (4h) and has a small but non-zero chance of solving everything quickly. If it fails (expected), Path 1 is the most reliable approach and closes the most sorries. Path 2 is a middle ground but the backward direction is uncertain.

The key strategic insight: Frame.lean's bx_le-based truth lemma for Until is an architectural dead end. Rather than trying to fix it, build a separate completeness path that uses a model with the right ordering. This aligns with how standard completeness proofs actually work.

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|-----------------|------------|
| A | bx_le deep analysis | completed | Concrete non-totality example; positional vs information ordering distinction; "junk points" insight | HIGH |
| B | Literature survey | completed | BX3 derivability; detailed BX7 case analysis sketch; 6 strategies ranked | MEDIUM |
| C | Critic | completed | D1/D3 elimination via BX7; factual corrections (box sorry, BXPoints, Realization); inductive truth lemma direction | HIGH |
| D | Strategic horizons | completed | Safety/liveness reframing; derived unfolding theorem; finite model bypass architecture; 3-track recommendation | MEDIUM-HIGH |

## References

- Burgess 1982 "Axioms for tense logic I: Since and Until" (Notre Dame J. Formal Logic)
- Goldblatt 1992 "Logics of Time and Computation" (CSLI, 2nd ed.)
- Venema 1993 "Completeness via Completeness"
- Blackburn/de Rijke/Venema 2001 "Modal Logic" (Cambridge)
- Reynolds 2003 temporal logic completeness proofs
- Verbrugge "Completeness by construction for tense logics"

# Research Report: Task #123 — ω + ω* Gap Elimination

**Task**: fix_c5_witness_bot_and_prove_icc_finite
**Date**: 2026-05-12
**Mode**: Team Research (4 teammates)
**Session**: sess_1778604286_c5307e
**Round**: 13

## Summary

Four teammates investigated how established methods rule out ω + ω* gaps in temporal logic canonical constructions. A clear consensus emerges: **Doets's Claim 10 via the modified Löb axiom (Z1), derivable from Prior-UZ, is the correct mechanism.** The irreflexivity rule is irrelevant. Construction-specific bot-guard handles finite stages but not the limit. No existing formalization exists — this would be novel.

## Key Findings

### 1. IRR Does Not Help (Teammate A)
The irreflexivity rule ensures irreflexive accessibility but cannot distinguish ω + ω* from Z (both are irreflexive). Gap elimination comes from Prior-UZ, not IRR. Reynolds explicitly notes his axiomatization does not use IRR.

### 2. Doets Claim 10 Is the Exact Mechanism (Teammate B)
The modified Löb axiom `G(Gp → p) → (FGp → Gp)` (= Z1) forces every bounded definable set to have a maximum. Proof sketch (from Doets pp. 91-92): if φ-set is bounded with no max, pick m below extent. m satisfies F(φ) and FG(¬φ). Z1 gives G(¬φ) at m. But m has F(φ) — some future point has φ. Contradiction with G(¬φ).

**Prior-UZ implies Z1** (standard derivation). Our system has Prior-UZ. Therefore Z1 holds semantically.

### 3. Prior-UZ Forces Non-Constant Models (Key Insight)
Prior-UZ (`F(p) → U(p, ¬p)`) is incompatible with constant models: if p ∈ MCS everywhere, then F(p) holds, but U(p, ¬p) requires a point with ¬p — impossible in a constant model. Therefore the construction MUST produce non-constant MCS labels. There MUST exist a formula distinguishing orbit from above-orbit points.

### 4. Construction Bot-Guard Handles Finite Stages (Teammate C)
For adjacent dom(N) points x (orbit) and y (above-orbit), the C5-bot witness at x enters dom(N) and adjacency forces z = y. This eliminates gaps at each finite stage. But finite-stage gap-freeness doesn't directly imply limit gap-freeness.

### 5. No Existing Formalization (Teammate D)
No proof assistant has formalized tense logic completeness with Since/Until. Novel reference found: Gabbay/Hodkinson/Reynolds 1993 "Temporal expressive completeness in the presence of gaps."

## Synthesis: The Proof Path

### The Doets/Z1 Approach (Recommended, ~100-200 lines)

**Step 1**: Derive Z1 from Prior-UZ in the proof system (~20-30 lines, standard temporal logic derivation using the discreteness axiom)

**Step 2**: Z1 holds semantically at all limit_dom points (via theorem_in_mcs + truth lemma)

**Step 3**: In the gap-at-L scenario, find a discriminating formula φ:
- Prior-UZ forces non-constant models → ∃ φ with φ ∈ limit_f(x) for some orbit x but ¬φ ∈ limit_f(y) for some above-orbit y
- By pigeonhole on finite Sub(A), infinitely many orbit points share the same restricted MCS Γ
- Pick any φ ∈ Γ that does NOT hold at above-orbit points near the gap
- The set {z : φ ∈ limit_f(z)} includes infinitely many orbit points (below L), is bounded above by b, has no maximum (its sup is L, no domain point at L)

**Step 4**: Z1 says this bounded definable set must have a maximum. Contradiction.

### Risk: Finding the Discriminating Formula
The proof needs ∃ φ distinguishing orbit from above-orbit. Prior-UZ guarantees non-constancy but doesn't hand us the specific φ. The formalization needs:
- Show orbit MCS ≠ above-orbit MCS (via Prior-UZ semantics)
- Extract a concrete φ from the symmetric difference

### Confidence: 75%
Higher than any prior approach because it uses the AXIOM directly rather than construction dynamics.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | IRR rule analysis | completed | high |
| B | Z1 proof mechanisms | completed | high |
| C | Construction dynamics | completed | high |
| D | Online search | completed | medium |
